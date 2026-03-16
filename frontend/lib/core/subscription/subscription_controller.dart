import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../auth/auth_state.dart';
import '../../features/settings/data/user_profile_repository.dart';
import '../../shared/models/generation_access.dart';
import '../../shared/models/user_profile.dart';
import 'subscription_service.dart';
import 'subscription_state.dart';
import 'subscription_status.dart';

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, SubscriptionState>(
  SubscriptionController.new,
);

class SubscriptionController extends Notifier<SubscriptionState> {
  late final SubscriptionService _subscriptionService;
  late final UserProfileRepository _userProfileRepository;

  @override
  SubscriptionState build() {
    _subscriptionService = ref.read(subscriptionServiceProvider);
    _userProfileRepository = ref.read(userProfileRepositoryProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      Future<void>(() => _handleAuthState(next));
    });

    Future<void>(() => _handleAuthState(ref.read(authControllerProvider)));
    return const SubscriptionState.initial();
  }

  Future<bool?> checkGenerationAccess() async {
    final access = await refreshAccess();
    return access?.canGenerate;
  }

  Future<GenerationAccess?> refreshAccess({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(
        subscriptionStatus: state.isSubscribed
            ? SubscriptionStatus.premium
            : SubscriptionStatus.loading,
        clearError: true,
        clearInfo: true,
      );
    }

    try {
      final access = await _userProfileRepository.fetchGenerationAccess();
      _applyAccess(access);
      return access;
    } catch (error) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        errorMessage: '$error',
        clearInfo: true,
      );
      return null;
    }
  }

  Future<void> loadOfferings() async {
    if (state.isLoadingOfferings) {
      return;
    }

    state = state.copyWith(
      isLoadingOfferings: true,
      clearError: true,
      clearInfo: true,
    );

    try {
      final offerings = await _subscriptionService.fetchOfferings();
      final monthlyProduct = _subscriptionService.pickMonthlyProduct(offerings);

      state = state.copyWith(
        offerings: offerings,
        monthlyProduct: monthlyProduct,
        setMonthlyProductToNull: monthlyProduct == null,
        isLoadingOfferings: false,
        errorMessage: offerings.isEmpty
            ? 'RevenueCat offerings are not available yet. Configure the SDK key and monthly product.'
            : null,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingOfferings: false,
        subscriptionStatus: SubscriptionStatus.error,
        errorMessage: '$error',
      );
    }
  }

  Future<bool> purchaseMonthly() async {
    if (state.monthlyProduct == null) {
      await loadOfferings();
    }

    final product = state.monthlyProduct;
    if (product == null) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        errorMessage: 'Monthly subscription product is not available.',
      );
      return false;
    }

    state = state.copyWith(
      subscriptionStatus: SubscriptionStatus.purchasing,
      isProcessingPurchase: true,
      clearError: true,
      clearInfo: true,
    );

    try {
      final entitlementActive = await _subscriptionService.purchase(product);
      return _finalizePurchaseOrRestore(entitlementActive);
    } catch (error) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        isProcessingPurchase: false,
        errorMessage: '$error',
      );
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    state = state.copyWith(
      subscriptionStatus: SubscriptionStatus.restoring,
      isProcessingPurchase: true,
      clearError: true,
      clearInfo: true,
    );

    try {
      final entitlementActive = await _subscriptionService.restorePurchases();
      return _finalizePurchaseOrRestore(entitlementActive);
    } catch (error) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        isProcessingPurchase: false,
        errorMessage: '$error',
      );
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await ref.read(authControllerProvider.notifier).refreshCurrentUser();
    final authState = ref.read(authControllerProvider);
    if (authState.user != null) {
      _applyUserProfile(authState.user!);
    }
  }

  Future<bool> _finalizePurchaseOrRestore(bool entitlementActive) async {
    if (!entitlementActive) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.error,
        isProcessingPurchase: false,
        errorMessage:
            'RevenueCat did not report an active premium entitlement for this account.',
      );
      return false;
    }

    for (var attempt = 0; attempt < 5; attempt++) {
      final access = await refreshAccess(silent: true);
      if (access != null && access.subscribed && access.canGenerate) {
        await ref.read(authControllerProvider.notifier).refreshCurrentUser();
        final authState = ref.read(authControllerProvider);
        if (authState.user != null) {
          _applyUserProfile(authState.user!);
        } else {
          _applyAccess(access);
        }
        state = state.copyWith(
          subscriptionStatus: SubscriptionStatus.premium,
          isProcessingPurchase: false,
          infoMessage: 'Premium unlocked. You can now generate decks.',
          clearError: true,
        );
        return true;
      }

      if (attempt < 4) {
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    state = state.copyWith(
      subscriptionStatus: SubscriptionStatus.awaitingBackendSync,
      isProcessingPurchase: false,
      infoMessage:
          'Purchase completed. Waiting for backend sync from the RevenueCat webhook.',
      clearError: true,
    );
    return false;
  }

  Future<void> _handleAuthState(AuthState authState) async {
    if (authState.isLoading) {
      state = state.copyWith(
        subscriptionStatus: SubscriptionStatus.loading,
        clearError: true,
        clearInfo: true,
      );
      return;
    }

    if (!authState.isAuthenticated || authState.user == null) {
      await _subscriptionService.logOut();
      state = const SubscriptionState.signedOut();
      return;
    }

    _applyUserProfile(authState.user!);

    if (authState.user!.revenueCatUserId.isNotEmpty) {
      await _subscriptionService.logIn(authState.user!.revenueCatUserId);
    }

    await refreshAccess(silent: true);
  }

  void _applyUserProfile(UserProfile userProfile) {
    state = state.copyWith(
      isSubscribed: userProfile.isSubscribed,
      freeGenerationsUsed: userProfile.freeGenerationsUsed,
      freeGenerationsRemaining: userProfile.freeGenerationsRemaining,
      maxCardsAllowed: userProfile.maxCardsAllowed,
      canGenerate:
          userProfile.isSubscribed || userProfile.freeGenerationsRemaining > 0,
      subscriptionStatus: userProfile.isSubscribed
          ? SubscriptionStatus.premium
          : SubscriptionStatus.free,
      clearError: true,
    );
  }

  void _applyAccess(GenerationAccess access) {
    state = state.copyWith(
      isSubscribed: access.subscribed,
      freeGenerationsUsed: access.freeGenerationsUsed,
      freeGenerationsRemaining: access.freeGenerationsRemaining,
      maxCardsAllowed: access.maxCardsAllowed,
      canGenerate: access.canGenerate,
      subscriptionStatus: access.subscribed
          ? SubscriptionStatus.premium
          : SubscriptionStatus.free,
      isProcessingPurchase: false,
      clearError: true,
    );
  }
}
