# Architecture Guide — Care Life Touch

## Overview

**Care Life Touch** is a Flutter drugs management app using **GetX** with **MVC + Repository Pattern**.

```
View → Controller → Repository → Provider
```

| Layer | Responsibility |
|---|---|
| **View** | UI only, no logic |
| **Controller** | State management via Rx observables |
| **Repository** | Business logic, data transformation, caching |
| **Provider** | Raw API calls & local storage access |

---

## Tech Stack

| Package | Purpose |
|---|---|
| `get ^4.7.3` | State, routing, dependency injection |
| `shared_preferences ^2.5.4` | Token, settings, session persistence |
| `logger ^2.6.2` | Structured console logging |
| `google_fonts ^8.0.2` | Typography |
| `flutter_svg ^2.0.10` | SVG asset rendering |
| `carousel_slider ^5.1.2` | Home banner slider |
| `flutter_rating_bar ^4.0.1` | Product ratings |
| `flutter_slidable ^4.0.3` | Swipeable list items (cart) |
| `smooth_page_indicator ^2.0.1` | Onboarding page dots |
| `image_picker ^1.0.7` | Profile image upload |
| `permission_handler ^11.3.0` | Runtime permissions |
| `pinput ^6.0.2` | OTP input field |

---

## File Structure

```
lib/
├── main.dart                        # App entry: init StorageService, launch GetMaterialApp
└── app/
    ├── core/
    │   ├── constants/
    │   │   └── app_constants.dart   # App-wide constants (appName, URLs, keys)
    │   ├── theme/
    │   │   └── app_theme.dart       # Light theme definition
    │   ├── utils/
    │   │   ├── app_logger.dart      # Logger wrapper (info, error, navigation)
    │   │   ├── helpers.dart         # Utility functions
    │   │   └── validators.dart      # Form validation logic
    │   └── values/                  # Colors, dimensions, text styles
    │
    ├── data/
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── medicine_model.dart
    │   │   ├── cart_model.dart
    │   │   └── notification_model.dart
    │   ├── providers/
    │   │   ├── api_provider.dart    # HTTP client (GetConnect)
    │   │   └── storage_provider.dart# SharedPreferences wrapper
    │   └── repositories/
    │       └── product_repository.dart # Product business logic
    │
    ├── modules/
    │   ├── splash/                  # Launch screen, auth redirect
    │   ├── onboarding/              # First-launch walkthrough (models + controller)
    │   ├── auth/
    │   │   ├── controllers/
    │   │   │   ├── auth_controller.dart           # Login & Register
    │   │   │   └── forgot_password_controller.dart
    │   │   └── views/
    │   │       ├── login_view.dart
    │   │       ├── register_view.dart
    │   │       ├── forgot_password_view.dart
    │   │       └── reset_password_view.dart
    │   ├── shell/                   # Bottom navigation scaffold
    │   ├── home/
    │   │   ├── models/              # Home-specific models (banners, categories)
    │   │   └── views/
    │   │       ├── home_view.dart
    │   │       ├── all_brands_view.dart
    │   │       ├── all_categories_view.dart
    │   │       └── widgets/         # Home-scoped widgets
    │   ├── products/                # Product listing & filtering
    │   ├── product_details/         # Product detail + reviews + overview
    │   ├── cart/                    # Cart management & checkout
    │   ├── notification/            # Notification list
    │   ├── more/                    # Profile, order history, settings
    │   └── legal/                   # Terms, Privacy Policy, About
    │
    ├── routes/
    │   ├── app_routes.dart          # Route name constants
    │   └── app_pages.dart           # Route → View + Binding mapping
    │
    └── global_widgets/
        ├── primary_appbar.dart
        ├── custom_button.dart
        ├── custom_text_field.dart
        ├── loading_widget.dart
        ├── empty_state_widget.dart
        ├── add_to_cart_modal.dart
        ├── otp_verification_dialog.dart
        ├── info_modal.dart
        └── terms_rich_text.dart
```

---

## Navigation Flow

```
Splash
  ├── [first launch] → Onboarding → Login
  ├── [logged out]   → Login → Register / Forgot Password → Reset Password
  └── [logged in]    → Shell (Bottom Nav)
                          ├── Home → All Brands / All Categories → Products → Product Details
                          ├── Products
                          ├── Cart → Checkout
                          ├── Notification
                          └── More → Profile / Order History / Legal
```

---

## Defined Routes

| Route | Path |
|---|---|
| `SPLASH` | `/splash` |
| `ONBOARDING` | `/onboarding` |
| `HOME` | `/home` |
| `LOGIN` | `/login` |
| `REGISTER` | `/register` |
| `FORGOT_PASSWORD` | `/forgot-password` |
| `FORGOT_PASSWORD_RESET` | `/forgot-password-reset` |
| `PRODUCTS` | `/products` |
| `PRODUCT_DETAILS` | `/product-details` |
| `MEDICINE_OVERVIEW` | `/medicine-overview` |
| `PRODUCT_REVIEWS` | `/product-reviews` |
| `CART` | `/cart` |
| `CHECKOUT` | `/checkout` |
| `ORDER_HISTORY` | `/order-history` |
| `PROFILE` | `/profile` |
| `NOTIFICATION` | `/notification` |
| `TERMS / PRIVACY / ABOUT` | Legal routes |

---

## App Entry Point

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = StorageService();
  await storage.init();         // Init SharedPreferences
  Get.put(storage);             // Register globally
  runApp(const MyApp());
}
```

`StorageService` is the only service bootstrapped at startup. Everything else is lazy-loaded through module `Bindings`.

---

## Adding a New Feature

1. **Model** → `lib/app/data/models/`
2. **Provider method** → `api_provider.dart` or `storage_provider.dart`
3. **Repository** → `lib/app/data/repositories/`
4. **Controller** → `modules/<feature>/controllers/`
5. **View** → `modules/<feature>/views/`
6. **Binding** → `modules/<feature>/bindings/`
7. **Route** → `app_routes.dart` + `app_pages.dart`

---

## Key Principles

- **Single responsibility**: each layer has exactly one job.
- **Lazy DI**: dependencies are injected via Bindings, not at startup.
- **Reactive state**: all mutable state uses `.obs` + `Obx()`.
- **No logic in Views**: controllers and repositories absorb all logic.
- **Reusable UI**: shared widgets live in `global_widgets/`, screen-specific widgets live in `modules/<feature>/views/widgets/`.