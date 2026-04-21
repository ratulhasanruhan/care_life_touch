import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/address_model.dart';
import '../../../data/repositories/address_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../global_widgets/info_modal.dart';
import '../../../routes/app_pages.dart';
import '../../address/views/routes.dart';
import '../models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../products/models/products_query.dart';

/// Home Controller - Manages home screen state and logic
class HomeController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final selectedIndex = 0.obs;

  // Header location state
  final isResolvingLocation = false.obs;
  final hasLocationError = false.obs;
  final locationText = 'Choose delivery location'.obs;
  final selectedHomeAddress = Rxn<AddressModel>();

  // Product data
  final trendingProducts = <ProductModel>[].obs;
  final newProducts = <ProductModel>[].obs;
  final offerProducts = <ProductModel>[].obs;
  final categories = <Map<String, String>>[].obs;
  final brands = <Map<String, String>>[].obs;
  final banners = <String>[].obs;
  final unreadNotificationCount = 0.obs;
  final _searchSuggestions = <String>[].obs;

  // Cart controller
  late CartController cartController;
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final NotificationRepository _notificationRepository = Get.find<NotificationRepository>();
  final PageRepository _pageRepository = Get.find<PageRepository>();
  final AddressRepository _addressRepository = Get.find<AddressRepository>();

  static const _categoryFallbackImages = <String>[
    'assets/demo/cat_1.png',
    'assets/demo/cat__2.png',
    'assets/demo/cat_3.png',
    'assets/demo/cat_4.png',
  ];

  static const _brandFallbackImages = <String>[
    'assets/demo/company_1.png',
    'assets/demo/company_2.png',
    'assets/demo/company_3.png',
    'assets/demo/company_4.png',
  ];

  static const _bannerFallbackImages = <String>[
    'assets/demo/banner_1.png',
    'assets/demo/banner_2.png',
  ];

   List<String> get searchSuggestions => _searchSuggestions;

    void _updateSearchSuggestions() {
      final products = <String>[];

      String? addValue(String value) {
        final text = value.trim();
        if (text.isNotEmpty && !_isLikelyId(text)) {
          return text;
        }
        return null;
      }

      // Collect only product names
      for (final product in [...trendingProducts, ...newProducts, ...offerProducts]) {
        final name = addValue(product.name);
        if (name != null && name.isNotEmpty) {
          products.add(name);
        }
      }

      // Deduplicate while preserving order
      final deduplicatedProducts = _deduplicateList(products);

      // Take first 20 items
      final final_suggestions = deduplicatedProducts.take(20).toList();
      _searchSuggestions.assignAll(final_suggestions);
    }

    /// Deduplicates a list while preserving order
    List<String> _deduplicateList(List<String> list) {
      final seen = <String>{};
      final result = <String>[];
      for (final item in list) {
        final key = item.toLowerCase();
        if (seen.add(key)) {
          result.add(item);
        }
      }
      return result;
    }

   /// Check if a string looks like an ID (MongoDB ObjectId, UUID, or similar)
   bool _isLikelyId(String value) {
     // MongoDB ObjectId pattern (24 hex characters)
     if (RegExp(r'^[a-f0-9]{24}$', caseSensitive: false).hasMatch(value)) {
       return true;
     }
     // UUID pattern
     if (RegExp(r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$', caseSensitive: false).hasMatch(value)) {
       return true;
     }
     // Generic numeric ID pattern (all digits)
     if (RegExp(r'^\d+$').hasMatch(value)) {
       return true;
     }
     return false;
   }

  @override
  void onInit() {
    super.onInit();
    cartController = Get.find<CartController>();
    loadData();
    _loadUnreadNotifications();
    _requestLocationPermission();
    resolveHomeLocation();
  }

  /// Load initial data
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      AppLogger.info('Loading home data...');

      late List<ProductModel> trending;
      late List<ProductModel> newArrival;
      late List<ProductModel> offers;
      late List<Map<String, dynamic>> apiCategories;
      late List<Map<String, dynamic>> apiBrands;
      late List<String> apiBanners;

      try {
        trending = await _productRepository.getTrendingProducts(limit: 10);
      } catch (e) {
        AppLogger.warning('Failed to load trending products', e);
        trending = const [];
      }

      try {
        newArrival = await _productRepository.getNewProducts(limit: 10);
      } catch (e) {
        AppLogger.warning('Failed to load new products', e);
        newArrival = const [];
      }

      try {
        offers = await _productRepository.getOfferProducts(limit: 10, minDiscount: 1);
      } catch (e) {
        AppLogger.warning('Failed to load offer products', e);
        offers = const [];
      }

      try {
        apiCategories = await _productRepository.getAllCategories();
      } catch (e) {
        AppLogger.warning('Failed to load categories', e);
        apiCategories = const [];
      }

      try {
        apiBrands = await _productRepository.getAllBrands();
      } catch (e) {
        AppLogger.warning('Failed to load brands', e);
        apiBrands = const [];
      }

      try {
        apiBanners = await _pageRepository.getHomeBanners();
      } catch (e) {
        AppLogger.warning('Failed to load banners', e);
        apiBanners = const [];
      }

       trendingProducts.assignAll(trending.take(6));
       newProducts.assignAll(newArrival.take(6));
       offerProducts.assignAll(offers.take(6));
       categories.assignAll(_normalizeCategories(apiCategories));
       brands.assignAll(_normalizeBrands(apiBrands));
       banners.assignAll(apiBanners.isEmpty ? _bannerFallbackImages : apiBanners);

       // Update search suggestions after loading all data
       _updateSearchSuggestions();

       AppLogger.success('Home data loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      unreadNotificationCount.value = await _notificationRepository.getUnreadCount();
    } catch (e) {
      unreadNotificationCount.value = 0;
      AppLogger.warning('Failed to load unread notification count', e);
    }
  }

  /// Request location permission (approximate location)
  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();

      if (status.isGranted) {
        AppLogger.success('Location permission granted');
      } else if (status.isDenied) {
        AppLogger.info('Location permission denied');
      } else if (status.isPermanentlyDenied) {
        AppLogger.warning('Location permission permanently denied');
        _showLocationSettingsModal();
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to request location permission', e, stackTrace);
    }
  }

  /// Show info modal to open settings when permission is permanently denied
  void _showLocationSettingsModal() {
    InfoModal.show(
      title: 'Enable Location Access',
      description:
          'Location access has been disabled. Please enable it in app settings to provide better delivery estimates.',
      buttonText: 'Open Settings',
      imagePath: 'assets/images/ic_location_access.png',
      onPressed: () {
        Get.back();
        openAppSettings();
      },
    );
  }

  /// Resolve and load the home location address
  Future<void> resolveHomeLocation() async {
    isResolvingLocation.value = true;
    hasLocationError.value = false;

    try {
      final addresses = await _addressRepository.getMyAddresses();
      if (addresses.isEmpty) {
        locationText.value = 'Choose delivery location';
        selectedHomeAddress.value = null;
        return;
      }

      AddressModel preferred = addresses.first;
      for (final item in addresses) {
        if (item.isDefault) {
          preferred = item;
          break;
        }
      }

      selectedHomeAddress.value = preferred;
      locationText.value = preferred.details.isEmpty ? 'Choose delivery location' : preferred.details;
    } catch (e, stackTrace) {
      hasLocationError.value = true;
      locationText.value = 'Location unavailable. Tap to choose';
      AppLogger.error('Failed to resolve home location', e, stackTrace);
    } finally {
      isResolvingLocation.value = false;
    }
  }

  /// Handle location tap to open address picker
  Future<void> onLocationTap() async {
    final result = await Get.toNamed(AddressRoutes.addresses, arguments: {'pickerMode': true});

    if (result is AddressModel) {
      selectedHomeAddress.value = result;
      locationText.value = result.details.isEmpty ? 'Choose delivery location' : result.details;
      hasLocationError.value = false;
    } else {
      await resolveHomeLocation();
    }
  }

  /// Refresh data
  Future<void> onRefresh() async {
    await Future.wait([loadData(), resolveHomeLocation(), _loadUnreadNotifications()]);
  }

  /// Navigate to category
  void onCategoryTap(String category) {
    AppLogger.debug('Category tapped: $category');
    // TODO: Navigate to category page
    AppHelpers.showInfoSnackbar(message: 'Navigating to $category', title: 'Category');
  }

  List<Map<String, String>> _normalizeCategories(List<Map<String, dynamic>> source) {
    if (source.isEmpty) {
      return List<Map<String, String>>.generate(_categoryFallbackImages.length, (index) {
        final fallbackName = ['Pharma', 'Unani', 'Tablet', 'Capsule'][index];
        return {
          'id': fallbackName,
          'name': fallbackName,
          'query': fallbackName,
          'image': _categoryFallbackImages[index],
        };
      });
    }

    return source.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final id = (item['_id'] ?? item['id'] ?? '').toString();
      final name = (item['name'] ?? 'Category').toString();
      final image = _pickImage(item) ?? _categoryFallbackImages[index % _categoryFallbackImages.length];
      return {
        'id': id,
        'name': name,
        'query': id.isEmpty ? name : id,
        'image': image,
      };
    }).toList();
  }

  List<Map<String, String>> _normalizeBrands(List<Map<String, dynamic>> source) {
    if (source.isEmpty) {
      return const [
        {'id': 'Incepta', 'name': 'Incepta Pharmaceu...', 'query': 'Incepta', 'image': 'assets/demo/company_1.png'},
        {'id': 'ACME', 'name': 'ACME Pharmaceu...', 'query': 'ACME', 'image': 'assets/demo/company_2.png'},
        {'id': 'Opsonin', 'name': 'Opsonin Pharmaceu...', 'query': 'Opsonin', 'image': 'assets/demo/company_3.png'},
        {'id': 'Aristopharma', 'name': 'Aristopharma Pharmaceu...', 'query': 'Aristopharma', 'image': 'assets/demo/company_4.png'},
      ];
    }

    return source.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final id = (item['_id'] ?? item['id'] ?? '').toString();
      final name = (item['name'] ?? 'Brand').toString();
      final image = _pickImage(item) ?? _brandFallbackImages[index % _brandFallbackImages.length];
      return {
        'id': id,
        'name': name,
        'query': id.isEmpty ? name : id,
        'image': image,
      };
    }).toList();
  }

  String? _pickImage(Map<String, dynamic> source) {
    final keys = ['logo', 'thumbnail', 'image', 'icon', 'url'];
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value is Map) {
        final nested = value['url'];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim();
        }
      }
    }
    return null;
  }

  /// Navigate to brand
  void onBrandTap(String brand) {
    AppLogger.debug('Brand tapped: $brand');
    // TODO: Navigate to brand page
    AppHelpers.showInfoSnackbar(message: 'Navigating to $brand', title: 'Brand');
  }

  void onNotificationTap() {
    Get.toNamed(Routes.NOTIFICATION)?.then((_) => _loadUnreadNotifications());
  }

  /// Handle search
  void onSearch(String query) {
    if (query.trim().isEmpty) {
      AppHelpers.showInfoSnackbar(message: 'Please enter a search query', title: 'Search');
      return;
    }

    AppLogger.debug('Search query: $query');
    Get.toNamed(
      Routes.PRODUCTS,
      arguments: ProductsQuery(
        type: ProductListingType.all,
        title: 'Search Results',
        keyword: query.trim(),
      ),
    );
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
