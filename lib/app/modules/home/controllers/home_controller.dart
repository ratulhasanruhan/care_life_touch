import 'package:get/get.dart';

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
  }

  /// Load initial data
  Future<void> loadData() async {
    try {
      isLoading.value = true;
      
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
    } catch (e) {
      // Handle error
      print('Error loading data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh data
  Future<void> onRefresh() async {
    await loadData();
  }

  /// Navigate to category
  void onCategoryTap(String category) {
    // TODO: Navigate to category page
    Get.snackbar('Category', 'Navigating to $category');
  }

  /// Navigate to medicine details
  void onMedicineTap(String medicine) {
    // TODO: Navigate to medicine details page
    Get.snackbar('Medicine', 'Selected $medicine');
  }

  @override
  void onClose() {
    // Clean up resources
    super.onClose();
  }
}

