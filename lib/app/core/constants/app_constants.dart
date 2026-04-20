/// App Constants - Define all constant values here
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Care Life Touch';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://server.carelifetouch.com/api',
  );
  static const String uploadEndpoint = '/upload-image';

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000;
  static const int maxRequestRetries = 2;

  // Pagination
  static const int defaultPageSize = 20;

  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyLastLoginIdentifier = 'last_login_identifier';
  static const String keyLanguage = 'language';
  static const String keyTheme = 'theme_mode';
  static const String keyCart = 'cart_data';
  static const String keyAccountId = 'account_id';
  static const String keyReferenceId = 'reference_id';
  static const String keyUserRole = 'user_role';
  static const String keyPendingOtp = 'pending_otp';
  static const String keyPendingRegistration = 'pending_registration';
  static const String keyPendingRegistrationLocation = 'pending_registration_location';

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
