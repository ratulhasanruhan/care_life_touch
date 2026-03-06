import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    AppLogger.info('Splash screen initialized');
    _navigateToOnboarding();
  }

  /// Navigate to onboarding after delay
  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));
    AppLogger.navigation(Routes.ONBOARDING);
    Get.offNamed(Routes.ONBOARDING);
  }
}
