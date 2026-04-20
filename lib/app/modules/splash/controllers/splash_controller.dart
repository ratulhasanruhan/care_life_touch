import 'package:get/get.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/page_repository.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();
  late PageRepository _pageRepository;
  final splashLogo = ''.obs;
  final splashLogoLocalPath = ''.obs;
  final splashText = 'Care You Trust. Medicines You Need.'.obs;
  final isLoadingLogo = true.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.info('Splash screen initialized');
    _pageRepository = Get.find<PageRepository>();
    _loadAndCacheLogo();
  }

  /// Load logo from API and cache it
  Future<void> _loadAndCacheLogo() async {
    try {
      isLoadingLogo.value = true;

      // Fetch branding payload from API so we can use both logo and site name.
      final branding = await _pageRepository.getPageSettings('branding');
      final payload = branding['data'] is Map<String, dynamic>
          ? branding['data'] as Map<String, dynamic>
          : const <String, dynamic>{};

      final siteName = (payload['siteName'] ?? '').toString().trim();
      if (siteName.isNotEmpty) {
        splashText.value = siteName;
      }

      final logoUrl = (payload['logos'] is List && (payload['logos'] as List).isNotEmpty)
          ? (() {
              final firstLogo = (payload['logos'] as List).first;
              if (firstLogo is Map<String, dynamic>) {
                final url = firstLogo['url'];
                return url is String ? url.trim() : '';
              }
              if (firstLogo is Map) {
                final url = firstLogo['url'];
                return url is String ? url.trim() : '';
              }
              return '';
            })()
          : '';

      if (logoUrl.isNotEmpty) {
        splashLogo.value = logoUrl;
        AppLogger.success('Splash logo loaded: $logoUrl');

        // Use previously cached file immediately if available.
        try {
          final cached = await DefaultCacheManager().getFileFromCache(logoUrl);
          final file = cached?.file;
          if (file != null && await file.exists()) {
            splashLogoLocalPath.value = file.path;
          }
        } catch (e) {
          AppLogger.warning('Failed to read splash logo cache', e);
        }

        // Refresh cache in background and update local path.
        try {
          final file = await DefaultCacheManager().getSingleFile(logoUrl);
          if (await file.exists()) {
            splashLogoLocalPath.value = file.path;
          }
          AppLogger.success('Splash logo cached successfully');
        } catch (e) {
          AppLogger.warning('Failed to cache splash logo', e);
        }
      }
    } catch (e) {
      AppLogger.warning('Failed to load splash logo', e);
    } finally {
      isLoadingLogo.value = false;
      // Navigate after logo is loaded or after a timeout
      _navigateToNextScreen();
    }
  }

  /// Navigate to next screen after delay
  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final pendingRegistration = _storage.getPendingRegistration();
    if (pendingRegistration != null && pendingRegistration['accountId'] != null) {
      AppLogger.info('Resuming pending registration flow');
      Get.offNamed(
        Routes.REGISTER,
        arguments: {
          'resumePendingRegistration': true,
          'pendingRegistration': pendingRegistration,
        },
      );
      return;
    }

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
