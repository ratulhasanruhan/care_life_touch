import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../../../core/utils/app_logger.dart';
import '../../../data/providers/storage_provider.dart';
import '../models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final currentIndex = 0.obs;
  final StorageService _storage = Get.find<StorageService>();
  late PageController pageController;
  final pages = onboardingPages;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
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
