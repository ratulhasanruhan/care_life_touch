import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_logger.dart';
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

  // Cart controller
  late CartController cartController;

  @override
  void onInit() {
    super.onInit();
    // Initialize cart controller
    cartController = Get.put(CartController());
    loadData();
    _requestLocationPermission();
  }

  /// Load initial data
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      AppLogger.info('Loading home data...');

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // TODO: Replace with actual API call
      // final products = await productRepository.getTrendingProducts();
      // trendingProducts.value = products;

      // Load sample product data
      trendingProducts.value = _getSampleProducts(4);
      newProducts.value = _getSampleProducts(4);
      offerProducts.value = _getSampleProducts(4, hasOffer: true);

      AppLogger.success('Home data loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// Generate sample products
  List<ProductModel> _getSampleProducts(int count, {bool hasOffer = false}) {
    return List.generate(count, (index) {
      final isEven = index % 2 == 0;
      return ProductModel(
        id: 'product_${DateTime.now().millisecondsSinceEpoch}_$index',
        name: isEven ? 'Paracetamol' : 'Ibuprofen',
        brand: 'ACME Pharmaceuticals',
        price: 100,
        maxPrice: 150,
        moq: '20 Box',
        rating: 4.9,
        imagePath: isEven
            ? 'assets/demo/product_1.png'
            : 'assets/demo/product_2.png',
        hasOffer: hasOffer && isEven,
        offerLabel: 'SALE',
      );
    });
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
