part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const SPLASH = _Paths.SPLASH;
  static const ONBOARDING = _Paths.ONBOARDING;
  static const HOME = _Paths.HOME;
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const FORGOT_PASSWORD = _Paths.FORGOT_PASSWORD;
  static const FORGOT_PASSWORD_RESET = _Paths.FORGOT_PASSWORD_RESET;
  static const PRODUCT_DETAILS = _Paths.PRODUCT_DETAILS;
  static const MEDICINE_OVERVIEW = _Paths.MEDICINE_OVERVIEW;
  static const PRODUCT_REVIEWS = _Paths.PRODUCT_REVIEWS;
  static const PRODUCTS = _Paths.PRODUCTS;
  static const CART = _Paths.CART;
  static const CHECKOUT = _Paths.CHECKOUT;
  static const ORDER_HISTORY = _Paths.ORDER_HISTORY;
  static const ORDER_DETAILS = _Paths.ORDER_DETAILS;
  static const PROFILE = _Paths.PROFILE;
  static const SETTINGS = _Paths.SETTINGS;
  static const CHANGE_PASSWORD = _Paths.CHANGE_PASSWORD;
  static const NOTIFICATION = _Paths.NOTIFICATION;
  static const TERMS = LegalRoutes.terms;
  static const PRIVACY = LegalRoutes.privacy;
  static const ABOUT = LegalRoutes.about;
  // Add more routes as needed
}

abstract class _Paths {
  _Paths._();
  static const SPLASH = '/splash';
  static const ONBOARDING = '/onboarding';
  static const HOME = '/home';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const FORGOT_PASSWORD = '/forgot-password';
  static const FORGOT_PASSWORD_RESET = '/forgot-password-reset';
  static const PRODUCT_DETAILS = '/product-details';
  static const MEDICINE_OVERVIEW = '/medicine-overview';
  static const PRODUCT_REVIEWS = '/product-reviews';
  static const PRODUCTS = '/products';
  static const CART = '/cart';
  static const CHECKOUT = '/checkout';
  static const ORDER_HISTORY = '/order-history';
  static const ORDER_DETAILS = '/order-details';
  static const PROFILE = '/profile';
  static const SETTINGS = '/settings';
  static const CHANGE_PASSWORD = '/settings/change-password';
  static const NOTIFICATION = '/notification';
  // Add more paths as needed
}
