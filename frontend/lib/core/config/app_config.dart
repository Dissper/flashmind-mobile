class AppConfig {
  const AppConfig._();

  static const appName = 'FlashMind';

  // Override with --dart-define=API_BASE_URL=... when needed.
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const useMockBackend = bool.fromEnvironment(
    'USE_FRONTEND_MOCKS',
    defaultValue: true,
  );

  static const allowLoginBypass = bool.fromEnvironment(
    'ALLOW_LOGIN_BYPASS',
    defaultValue: true,
  );

  static const maxCards = 20;
  static const maxFileSizeLabel = '10 MB';
  static const supportedFileTypesLabel = 'PDF, DOCX, PPTX';
}
