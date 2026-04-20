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
      final normalized = _normalizeContent(content);
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
        final normalized = _normalizeContent(fallbackContent);
        if (normalized.isNotEmpty) {
          return normalized;
        }
      } catch (_) {
        // Keep trying fallback keys.
      }
    }

    return '';
  }

  String _normalizeContent(String text) {
    var normalized = text
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();

    if (normalized.isEmpty) {
      return '';
    }

    // Ensure markdown headers are on a new line if CMS content provides them inline.
    normalized = normalized.replaceAllMapped(
      RegExp(r'([^\n])[ \t]+(#{1,6})(?=[ \t]*\S)'),
      (match) => '${match.group(1)}\n${match.group(2)}',
    );

    // Allow compact headers like `##heading` by inserting a space after # markers.
    normalized = normalized.replaceAllMapped(
      RegExp(r'(^|\n)([ \t]*)(#{1,6})([^\s#\n])', multiLine: true),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)} ${match.group(4)}',
    );

    // Ensure inline bullet list markers start on a new line.
    normalized = normalized.replaceAllMapped(
      RegExp(r'([^\n])[ \t]+([*+-])[ \t]+'),
      (match) => '${match.group(1)}\n${match.group(2)} ',
    );

    // Ensure inline numbered list markers start on a new line.
    normalized = normalized.replaceAllMapped(
      RegExp(r'([^\n])[ \t]+(\d+[.)])[ \t]+'),
      (match) => '${match.group(1)}\n${match.group(2)} ',
    );

    // Also support compact list markers at line start like `-item` or `1.item`.
    normalized = normalized.replaceAllMapped(
      RegExp(r'(^|\n)([ \t]*)([*+-])(\S)', multiLine: true),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)} ${match.group(4)}',
    );
    normalized = normalized.replaceAllMapped(
      RegExp(r'(^|\n)([ \t]*)(\d+[.)])(\S)', multiLine: true),
      (match) => '${match.group(1)}${match.group(2)}${match.group(3)} ${match.group(4)}',
    );

    return normalized;
  }

  @override
  void onClose() {
    super.onClose();
  }
}
