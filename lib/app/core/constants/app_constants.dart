/// App Constants - Define all constant values here
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Care Life Touch';
  static const String appVersion = '1.0.0';

  // API Configuration (Update with your actual API)
  static const String baseUrl = 'https://api.example.com';
  static const String apiVersion = '/api/v1';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;

  // Pagination
  static const int defaultPageSize = 20;

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme_mode';
  static const String keyCart = 'cart_data';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Medicine Categories (Example)
  static const List<String> medicineCategories = [
    'Pain Relief',
    'Cold & Flu',
    'Vitamins & Supplements',
    'First Aid',
    'Prescription',
    'Personal Care',
    'Baby Care',
    'Health Devices',
  ];
}

