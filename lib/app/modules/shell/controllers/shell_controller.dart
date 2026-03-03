import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';
import '../../../routes/app_pages.dart';

/// Shell Controller - Manages navigation between main sections
class ShellController extends GetxController {
  // Current tab index
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('Shell controller initialized');
  }

  /// Handle tab change
  void onTabChanged(int index) {
    currentTabIndex.value = index;
    AppLogger.info('Tab changed to index: $index');

    switch (index) {
      case 0:
        // Home tab
        AppLogger.navigation(Routes.HOME);
        break;
      case 1:
        // Products tab
        AppLogger.navigation(Routes.PRODUCT_DETAILS);
        Get.toNamed(Routes.PRODUCT_DETAILS);
        break;
      case 2:
        // My Bag (Cart) tab
        AppLogger.navigation(Routes.CART);
        Get.toNamed(Routes.CART);
        break;
      case 3:
        // More (Profile) tab
        AppLogger.navigation(Routes.PROFILE);
        Get.toNamed(Routes.PROFILE);
        break;
    }
  }
}

