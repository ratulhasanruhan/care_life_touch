import 'package:get/get.dart';

import '../../../core/utils/app_logger.dart';
import '../../../data/repositories/page_repository.dart';
import '../routes.dart';

class LegalController extends GetxController {
  final isLoading = false.obs;
  final termsText = ''.obs;
  final privacyText = ''.obs;
  final aboutText = ''.obs;

  final PageRepository _pageRepository = Get.find<PageRepository>();

  void openTermsOfService() {
    Get.toNamed(LegalRoutes.terms);
  }

  void openPrivacyPolicy() {
    Get.toNamed(LegalRoutes.privacy);
  }

  void openAbout() {
    Get.toNamed(LegalRoutes.about);
  }

  @override
  void onInit() {
    super.onInit();
    loadPages();
  }

  Future<void> loadPages() async {
    try {
      isLoading.value = true;

      termsText.value = await _loadSinglePage(
        key: 'termsAndConditions',
        fallbacks: const ['terms', 'termsOfService'],
      );
      privacyText.value = await _loadSinglePage(
        key: 'privacyPolicy',
        fallbacks: const ['privacy'],
      );
      aboutText.value = await _loadSinglePage(
        key: 'aboutUs',
        fallbacks: const ['about'],
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _loadSinglePage({
    required String key,
    List<String> fallbacks = const [],
  }) async {
    try {
      final content = await _pageRepository.getPageBodyText(key);
      final normalized = _stripHtml(content);
      if (normalized.isNotEmpty) {
        return normalized;
      }
    } catch (error, stackTrace) {
      AppLogger.warning('Failed to load legal page: $key', error);
      AppLogger.error('Legal page stacktrace', error, stackTrace);
    }

    for (final fallbackKey in fallbacks) {
      try {
        final fallbackContent = await _pageRepository.getPageBodyText(fallbackKey);
        final normalized = _stripHtml(fallbackContent);
        if (normalized.isNotEmpty) {
          return normalized;
        }
      } catch (_) {
        // Keep trying fallback keys.
      }
    }

    return '';
  }

  String _stripHtml(String text) {
    if (text.trim().isEmpty) {
      return '';
    }
    return text
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
