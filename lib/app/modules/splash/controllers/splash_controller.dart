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
    _navigateToOnboarding();
  }

  /// Navigate to onboarding after delay
  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 2));

    final nextRoute = _storage.isLoggedIn
        ? Routes.HOME
        : (_storage.isOnboardingCompleted ? Routes.LOGIN : Routes.ONBOARDING);

    AppLogger.navigation(nextRoute);
    Get.offNamed(nextRoute);
  }
}
