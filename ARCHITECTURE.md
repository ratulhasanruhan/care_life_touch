# Architecture Guide

## Overview

Your app uses GetX with MVC + Repository Pattern. Here's how it works:

**View** → **Controller** → **Repository** → **Provider**

- **View**: Shows UI (no logic)
- **Controller**: Manages state with Rx observables
- **Repository**: Handles all data business logic
- **Provider**: Calls APIs and storage

## Why This Architecture?

**Reusability**: Write logic once, use everywhere. No duplicate code.

**Testability**: Easy to mock repositories and test without APIs.

**Maintainability**: Fix a bug in one place, it's fixed everywhere.

**Scalability**: Add new features without breaking existing ones.

## How Repository Works

The Repository is where all the magic happens. It:

1. Calls the Provider (API/storage)
2. Parses JSON to Models
3. Applies business rules (filter, validate)
4. Caches data locally
5. Returns clean data to Controller

Example:

```dart
// Provider - raw HTTP call
class ApiProvider {
  Future<Response> getData(String endpoint) async {
    return await httpClient.get(endpoint);
  }
}

// Repository - business logic
class MedicineRepository {
  Future<List<Medicine>> getMedicines() async {
    // 1. Fetch from API
    final response = await _api.getData('/medicines');
    
    // 2. Parse JSON to models
    final medicines = (response.body['data'] as List)
        .map((json) => Medicine.fromJson(json))
        .toList();
    
    // 3. Filter (business rules)
    final available = medicines
        .where((m) => m.isInStock && !m.isExpired)
        .toList();
    
    // 4. Cache locally
    await _storage.save('medicines', response.body);
    
    // 5. Return to controller
    return available;
  }
}

// Controller - use it simply
class HomeController extends GetxController {
  final MedicineRepository _repo;
  final medicines = <Medicine>[].obs;
  
  Future<void> loadMedicines() async {
    medicines.value = await _repo.getMedicines();
  }
}

// View - just display
class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemCount: controller.medicines.length,
      itemBuilder: (_, i) => Text(controller.medicines[i].name),
    ));
  }
}
```

## Storage Choice

**SharedPreferences** (what you're using) ✅

- Perfect for: tokens, preferences, small data
- Fast and lightweight
- No extra dependencies
- Works everywhere

Use this for tokens, themes, settings. You already have it set up - keep it as is.

**GetStorage** (add later if needed)

- Better for: large lists, offline cache, complex objects
- But adds ~50KB to app size

Only add GetStorage if you need to cache medicine lists for offline access.

## File Structure

```
lib/app/
├── data/
│   ├── models/              # Medicine, User, Cart models
│   ├── providers/           # API calls, local storage
│   └── repositories/        # Business logic
├── modules/
│   └── home/
│       ├── controllers/     # HomeController
│       ├── views/           # HomeView
│       └── bindings/        # Dependency injection
├── routes/                  # Navigation
├── core/
│   ├── theme/              # Colors, theme
│   ├── values/             # Dimensions, colors
│   ├── utils/              # Helpers, validators
│   └── constants/          # Constants
└── global_widgets/         # Reusable components
```

## Key Points

1. **Each layer has ONE job**: Don't mix UI logic with business logic
2. **Repositories handle complexity**: Controllers stay clean
3. **Dependency injection**: Use bindings to inject dependencies
4. **Rx observables**: Use `.obs` for reactive state
5. **No code duplication**: Reuse repositories across controllers

## Adding Features

Creating a new feature? Follow this pattern:

1. Create Model (if new data type)
2. Add Provider method (if calling API)
3. Add Repository class
4. Add Controller extending GetxController
5. Add View extending GetView
6. Add Binding extending Bindings
7. Add Route in app_routes.dart

Example: Adding a Search feature would take 15 minutes following this pattern.

---

Simple. Clean. Professional.

