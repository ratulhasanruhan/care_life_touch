import 'package:logger/logger.dart';

/// App Logger - Clean and simple logging
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No stack trace
      errorMethodCount: 5, // Stack trace for errors
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // Debug - for development info
  static void debug(String message, [dynamic data]) {
    _logger.d(message, error: data);
  }

  // Info - general info
  static void info(String message, [dynamic data]) {
    _logger.i(message, error: data);
  }

  // Warning - something might be wrong
  static void warning(String message, [dynamic data]) {
    _logger.w(message, error: data);
  }

  // Error - something went wrong
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Success - for successful operations
  static void success(String message, [dynamic data]) {
    _logger.i('✅ $message', error: data);
  }

  // API - for API calls
  static void api(String method, String endpoint, {dynamic data}) {
    _logger.i('🌐 $method $endpoint', error: data);
  }

  // Navigation - for route changes
  static void navigation(String route, [dynamic arguments]) {
    _logger.d('🧭 Navigating to: $route', error: arguments);
  }
}

