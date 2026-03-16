import '../config/app_config.dart';
import 'subscription_product.dart';
import 'subscription_status.dart';

class SubscriptionState {
  const SubscriptionState({
    required this.isSubscribed,
    required this.freeGenerationLimit,
    required this.freeGenerationsUsed,
    required this.freeGenerationsRemaining,
    required this.maxCardsAllowed,
    required this.canGenerate,
    required this.subscriptionStatus,
    required this.offerings,
    required this.monthlyProduct,
    required this.isLoadingOfferings,
    required this.isProcessingPurchase,
    required this.errorMessage,
    required this.infoMessage,
  });

  const SubscriptionState.initial()
      : isSubscribed = false,
        freeGenerationLimit = AppConfig.freeGenerationLimit,
        freeGenerationsUsed = 0,
        freeGenerationsRemaining = AppConfig.freeGenerationLimit,
        maxCardsAllowed = AppConfig.freeMaxCards,
        canGenerate = true,
        subscriptionStatus = SubscriptionStatus.unknown,
        offerings = const [],
        monthlyProduct = null,
        isLoadingOfferings = false,
        isProcessingPurchase = false,
        errorMessage = null,
        infoMessage = null;

  const SubscriptionState.signedOut()
      : isSubscribed = false,
        freeGenerationLimit = AppConfig.freeGenerationLimit,
        freeGenerationsUsed = 0,
        freeGenerationsRemaining = AppConfig.freeGenerationLimit,
        maxCardsAllowed = AppConfig.freeMaxCards,
        canGenerate = false,
        subscriptionStatus = SubscriptionStatus.signedOut,
        offerings = const [],
        monthlyProduct = null,
        isLoadingOfferings = false,
        isProcessingPurchase = false,
        errorMessage = null,
        infoMessage = null;

  final bool isSubscribed;
  final int freeGenerationLimit;
  final int freeGenerationsUsed;
  final int freeGenerationsRemaining;
  final int maxCardsAllowed;
  final bool canGenerate;
  final SubscriptionStatus subscriptionStatus;
  final List<SubscriptionProduct> offerings;
  final SubscriptionProduct? monthlyProduct;
  final bool isLoadingOfferings;
  final bool isProcessingPurchase;
  final String? errorMessage;
  final String? infoMessage;

  SubscriptionState copyWith({
    bool? isSubscribed,
    int? freeGenerationLimit,
    int? freeGenerationsUsed,
    int? freeGenerationsRemaining,
    int? maxCardsAllowed,
    bool? canGenerate,
    SubscriptionStatus? subscriptionStatus,
    List<SubscriptionProduct>? offerings,
    SubscriptionProduct? monthlyProduct,
    bool setMonthlyProductToNull = false,
    bool? isLoadingOfferings,
    bool? isProcessingPurchase,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return SubscriptionState(
      isSubscribed: isSubscribed ?? this.isSubscribed,
      freeGenerationLimit: freeGenerationLimit ?? this.freeGenerationLimit,
      freeGenerationsUsed: freeGenerationsUsed ?? this.freeGenerationsUsed,
      freeGenerationsRemaining:
          freeGenerationsRemaining ?? this.freeGenerationsRemaining,
      maxCardsAllowed: maxCardsAllowed ?? this.maxCardsAllowed,
      canGenerate: canGenerate ?? this.canGenerate,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      offerings: offerings ?? this.offerings,
      monthlyProduct: setMonthlyProductToNull
          ? null
          : monthlyProduct ?? this.monthlyProduct,
      isLoadingOfferings: isLoadingOfferings ?? this.isLoadingOfferings,
      isProcessingPurchase:
          isProcessingPurchase ?? this.isProcessingPurchase,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      infoMessage: clearInfo ? null : infoMessage ?? this.infoMessage,
    );
  }
}
