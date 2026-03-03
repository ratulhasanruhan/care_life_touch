import 'package:get/get.dart';
import '../../../core/utils/app_logger.dart';

/// Shell Controller - Manages navigation between main sections
class ShellController extends GetxController {
  // Current tab index
  final currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('Shell controller initialized');
  }

  /// Handle tab change inside the shell (no extra route pushes)
  void onTabChanged(int index) {
    currentTabIndex.value = index;
    AppLogger.info('Tab changed to index: $index');
  }
}
