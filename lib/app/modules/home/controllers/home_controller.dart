import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_logger.dart';
import '../../../global_widgets/info_modal.dart';

/// Home Controller - Manages home screen state and logic
class HomeController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final selectedIndex = 0.obs;

  // Example data
  final featuredMedicines = <String>[].obs;
  final categories = <String>[
    'Pain Relief',
    'Cold & Flu',
    'Vitamins',
    'First Aid',
    'Baby Care',
    'Personal Care',
  ].obs;

  @override
  void onInit() {
    super.onInit();
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
      // final medicines = await medicineRepository.getFeaturedMedicines();
      // featuredMedicines.value = medicines;
      
      featuredMedicines.value = [
        'Paracetamol',
        'Ibuprofen',
        'Vitamin C',
        'Cough Syrup',
      ];

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
      description: 'Location access has been disabled. Please enable it in app settings to provide better delivery estimates.',
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

  /// Navigate to medicine details
  void onMedicineTap(String medicine) {
    AppLogger.debug('Medicine tapped: $medicine');
    // TODO: Navigate to medicine details page
    Get.snackbar('Medicine', 'Selected $medicine');
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

