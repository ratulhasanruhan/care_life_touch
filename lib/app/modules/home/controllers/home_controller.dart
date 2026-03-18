import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/page_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../global_widgets/info_modal.dart';
import '../models/product_model.dart';
import '../../cart/controllers/cart_controller.dart';

/// Home Controller - Manages home screen state and logic
class HomeController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final selectedIndex = 0.obs;

  // Product data
  final trendingProducts = <ProductModel>[].obs;
  final newProducts = <ProductModel>[].obs;
  final offerProducts = <ProductModel>[].obs;
  final categories = <Map<String, String>>[].obs;
  final brands = <Map<String, String>>[].obs;
  final banners = <String>[].obs;

  // Cart controller
  late CartController cartController;
  final ProductRepository _productRepository = Get.find<ProductRepository>();
  final PageRepository _pageRepository = Get.find<PageRepository>();

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

  @override
  void onInit() {
    super.onInit();
    cartController = Get.find<CartController>();
    loadData();
    _requestLocationPermission();
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

      AppLogger.success('Home data loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
    } finally {
      isLoading.value = false;
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

  /// Refresh data
  Future<void> onRefresh() async {
    await loadData();
  }

  /// Navigate to category
  void onCategoryTap(String category) {
    AppLogger.debug('Category tapped: $category');
    // TODO: Navigate to category page
    Get.snackbar('Category', 'Navigating to $category');
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
    Get.snackbar('Brand', 'Navigating to $brand');
  }

  /// Handle search
  void onSearch(String query) {
    AppLogger.debug('Search query: $query');
    // TODO: Navigate to search results
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}
