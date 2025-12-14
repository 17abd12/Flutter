/// Environment Configuration Service
/// 
/// This service loads environment-specific configuration.
/// In production, you would use flutter_dotenv or similar package.
/// 
/// For now, this provides a centralized place for all environment configs.
class EnvConfig {
  // Singleton pattern
  static final EnvConfig _instance = EnvConfig._internal();
  factory EnvConfig() => _instance;
  EnvConfig._internal();

  // ============================================================
  // CONFIGURATION INSTRUCTIONS
  // ============================================================
  // 
  // 1. For local development: Update values directly here (NOT RECOMMENDED)
  // 2. For production: Use flutter_dotenv package (RECOMMENDED)
  //    - Add flutter_dotenv to pubspec.yaml
  //    - Create .env file (never commit this!)
  //    - Load with: await dotenv.load(fileName: ".env")
  // 
  // 3. For CI/CD: Set environment variables in your CI/CD pipeline
  // 
  // ============================================================

  /// API Base URL - CONFIGURE THIS FOR YOUR ENVIRONMENT
  /// 
  /// Development: 'http://localhost:8000'
  /// Production: 'https://your-api-server.com'
  /// Firebase Functions: 'https://us-central1-your-project.cloudfunctions.net'
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Environment name (development, staging, production)
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  /// Check if running in production
  static bool get isProduction => environment == 'production';

  /// Check if running in development
  static bool get isDevelopment => environment == 'development';

  // ============================================================
  // API Configuration
  // ============================================================

  /// Get the configured API base URL
  String getApiBaseUrl() {
    // You can add logic here to switch between different URLs
    // based on environment or other conditions
    return apiBaseUrl;
  }

  /// API timeout duration in seconds
  static const int apiTimeoutSeconds = 30;

  // ============================================================
  // Feature Flags (optional - for controlling features)
  // ============================================================

  /// Enable debug logging
  static const bool enableDebugLogging = bool.fromEnvironment(
    'DEBUG_LOGGING',
    defaultValue: true,
  );

  /// Enable analytics
  static const bool enableAnalytics = bool.fromEnvironment(
    'ENABLE_ANALYTICS',
    defaultValue: false,
  );

  // ============================================================
  // USAGE EXAMPLES
  // ============================================================
  // 
  // 1. Access API URL:
  //    final apiUrl = EnvConfig().getApiBaseUrl();
  // 
  // 2. Check environment:
  //    if (EnvConfig.isProduction) { ... }
  // 
  // 3. Run app with custom values:
  //    flutter run --dart-define=API_BASE_URL=https://api.example.com
  //    flutter run --dart-define=ENVIRONMENT=production
  // 
  // 4. Build with custom values:
  //    flutter build apk --dart-define=API_BASE_URL=https://api.example.com
  // 
  // ============================================================
}
