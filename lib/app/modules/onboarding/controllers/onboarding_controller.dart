import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';
import '../../../data/repositories/page_repository.dart';
import '../models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final currentIndex = 0.obs;
  final StorageService _storage = Get.find<StorageService>();
  late PageRepository _pageRepository;
  late PageController pageController;
  final pages = <OnboardingPage>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _pageRepository = Get.find<PageRepository>();
    _loadOnboardingData();
  }

  /// Load onboarding data from API or use fallback
  Future<void> _loadOnboardingData() async {
    try {
      isLoading.value = true;

      final banners = await _pageRepository.getOnboardingBanners();

      if (banners.isNotEmpty) {
        // Convert API banners to OnboardingPage model
        final apiPages = banners.map((banner) {
          return OnboardingPage(
            image: (banner['image'] ?? 'assets/images/onboard_1.png').toString(),
            title: (banner['title'] ?? 'Onboarding').toString(),
            subtitle: (banner['description'] ?? '').toString(),
          );
        }).toList();

        pages.assignAll(apiPages);
        AppLogger.success('Onboarding data loaded from API: ${apiPages.length} pages');
      } else {
        // Fallback to hardcoded data
        pages.assignAll(onboardingPages);
        AppLogger.info('Using fallback onboarding data');
      }
    } catch (e) {
      AppLogger.warning('Failed to load onboarding data', e);
      // Fallback to hardcoded data
      pages.assignAll(onboardingPages);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  /// Update current page index
  void updateIndex(int index) {
    currentIndex.value = index;
  }

  /// Navigate to next page
  void nextPage() {
    if (currentIndex.value < pages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    AppLogger.info('Onboarding completed');
    _storage.setOnboardingCompleted(true);
    AppLogger.navigation(Routes.LOGIN);
    Get.offNamed(Routes.LOGIN);
  }

  /// Skip onboarding
  void skipOnboarding() {
    AppLogger.info('Onboarding skipped');
    _storage.setOnboardingCompleted(true);
    AppLogger.navigation(Routes.LOGIN);
    Get.offNamed(Routes.LOGIN);
  }
}
