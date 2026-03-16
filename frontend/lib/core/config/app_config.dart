import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const appName = 'FlashMind';
  static const placeholderRevenueCatApiKey =
      'replace-with-revenuecat-public-sdk-key';

  // Override with --dart-define=API_BASE_URL=... when needed.
  static String get apiBaseUrl {
    const configured = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (configured.isNotEmpty) {
      return configured;
    }

    if (kIsWeb) {
      return 'http://localhost:8080';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8080',
      _ => 'http://localhost:8080',
    };
  }

  static const useMockBackend = bool.fromEnvironment(
    'USE_FRONTEND_MOCKS',
    defaultValue: false,
  );

  static const allowLoginBypass = bool.fromEnvironment(
    'ALLOW_LOGIN_BYPASS',
    defaultValue: true,
  );

  // TODO: Replace REVENUECAT_API_KEY with the public SDK key for the active mobile store target.
  static const revenueCatApiKey = String.fromEnvironment(
    'REVENUECAT_API_KEY',
    defaultValue: placeholderRevenueCatApiKey,
  );

  // TODO: Replace PRODUCT_ID with the monthly product configured in App Store Connect and Google Play.
  static const revenueCatProductId = String.fromEnvironment(
    'PRODUCT_ID',
    defaultValue: 'replace-me',
  );

  static const revenueCatEntitlementId = 'premium';
  static const freeGenerationLimit = 3;
  static const freeMaxCards = 10;
  static const premiumMaxCards = 20;
  static const maxCards = premiumMaxCards;
  static const maxFileSizeLabel = '10 MB';
  static const supportedFileTypesLabel = 'PDF, DOCX, PPTX';
}
