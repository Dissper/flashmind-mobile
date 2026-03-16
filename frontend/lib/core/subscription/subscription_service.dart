import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';
import '../utils/mock_app_repository.dart';
import 'subscription_product.dart';

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  return const SubscriptionService();
});

class SubscriptionService {
  const SubscriptionService();

  static bool _sdkInitialized = false;

  static Future<void> initializeSdk() async {
    if (_sdkInitialized || AppConfig.useMockBackend || !_supportsNativeStoreKit) {
      _sdkInitialized = true;
      return;
    }

    if (AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      _sdkInitialized = true;
      return;
    }

    final configuration = PurchasesConfiguration(AppConfig.revenueCatApiKey);
    await Purchases.configure(configuration);
    _sdkInitialized = true;
  }

  Future<void> logIn(String revenueCatUserId) async {
    if (AppConfig.useMockBackend ||
        !_supportsNativeStoreKit ||
        revenueCatUserId.isEmpty ||
        AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      return;
    }

    await Purchases.logIn(revenueCatUserId);
  }

  Future<void> logOut() async {
    if (AppConfig.useMockBackend ||
        !_supportsNativeStoreKit ||
        AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      return;
    }

    await Purchases.logOut();
  }

  Future<List<SubscriptionProduct>> fetchOfferings() async {
    if (AppConfig.useMockBackend) {
      return [
        SubscriptionProduct(
          id: AppConfig.revenueCatProductId,
          title: 'FlashMind Premium Monthly',
          description:
              'Unlimited deck generations and up to ${AppConfig.premiumMaxCards} cards per deck.',
          priceLabel: '\$4.99 / month',
          isMonthly: true,
        ),
      ];
    }

    if (!_supportsNativeStoreKit ||
        AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      return const [];
    }

    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) {
      return const [];
    }

    return current.availablePackages.map(_mapPackage).toList();
  }

  Future<bool> purchase(SubscriptionProduct product) async {
    if (AppConfig.useMockBackend) {
      MockAppRepository.instance.activatePremium();
      return true;
    }

    if (!_supportsNativeStoreKit ||
        AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      return false;
    }

    final sourcePackage = product.sourcePackage;
    if (sourcePackage is! Package) {
      throw Exception('Monthly RevenueCat package is not available.');
    }

    final customerInfo = await Purchases.purchasePackage(sourcePackage);
    return _hasPremiumEntitlement(customerInfo);
  }

  Future<bool> restorePurchases() async {
    if (AppConfig.useMockBackend) {
      MockAppRepository.instance.activatePremium();
      return true;
    }

    if (!_supportsNativeStoreKit ||
        AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      return false;
    }

    final customerInfo = await Purchases.restorePurchases();
    return _hasPremiumEntitlement(customerInfo);
  }

  Future<bool> hasActiveEntitlement() async {
    if (AppConfig.useMockBackend) {
      return MockAppRepository.instance.currentUser.isSubscribed;
    }

    if (!_supportsNativeStoreKit ||
        AppConfig.revenueCatApiKey == AppConfig.placeholderRevenueCatApiKey) {
      return false;
    }

    final customerInfo = await Purchases.getCustomerInfo();
    return _hasPremiumEntitlement(customerInfo);
  }

  SubscriptionProduct? pickMonthlyProduct(List<SubscriptionProduct> offerings) {
    for (final offering in offerings) {
      if (offering.isMonthly || offering.id == AppConfig.revenueCatProductId) {
        return offering;
      }
    }

    return offerings.isEmpty ? null : offerings.first;
  }

  SubscriptionProduct _mapPackage(Package package) {
    return SubscriptionProduct(
      id: package.storeProduct.identifier,
      title: package.storeProduct.title,
      description: package.storeProduct.description,
      priceLabel: package.storeProduct.priceString,
      isMonthly: package.packageType == PackageType.monthly,
      sourcePackage: package,
    );
  }

  bool _hasPremiumEntitlement(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active
        .containsKey(AppConfig.revenueCatEntitlementId);
  }

  static bool get _supportsNativeStoreKit {
    if (kIsWeb) {
      return false;
    }
    return Platform.isAndroid || Platform.isIOS;
  }
}
