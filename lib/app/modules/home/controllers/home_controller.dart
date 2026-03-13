import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_logger.dart';
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

  // Cart controller
  late CartController cartController;
  final ProductRepository _productRepository = Get.find<ProductRepository>();

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

      final allProducts = await _productRepository.getProducts();
      trendingProducts.value = allProducts.take(6).toList();
      newProducts.value = allProducts.reversed.take(6).toList();

      final discounted = await _productRepository.getDiscountedProducts();
      offerProducts.value = discounted.isNotEmpty
          ? discounted.take(6).toList()
          : allProducts.where((product) => product.hasOffer).take(6).toList();

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
