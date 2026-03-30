import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('Splash screen initialized');
    _navigateToNextScreen();
  }

  /// Navigate to next screen after delay
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    // Check if there's a pending OTP verification (registration in progress)
    final pendingOTP = _storage.getPendingOTP();
    if (pendingOTP != null && pendingOTP['accountId'] != null) {
      AppLogger.info('Resuming pending OTP verification');
      Get.offNamed(Routes.REGISTER, arguments: {'resumePending': true, 'pending': pendingOTP});
      return;
    }

    final nextRoute = _storage.isLoggedIn
        ? Routes.HOME
        : (_storage.isOnboardingCompleted ? Routes.LOGIN : Routes.ONBOARDING);

    AppLogger.navigation(nextRoute);
    Get.offNamed(nextRoute);
  }
}
