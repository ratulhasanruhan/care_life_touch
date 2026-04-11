import 'package:get/get.dart';

import '../providers/api_provider.dart';

class PageRepository {
  PageRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<Map<String, dynamic>> getPageSettings(String key) async {
    final response = await _api.getData('/get-page-settings/$key');
    return _toMap(response) ?? const <String, dynamic>{};
  }

  Future<String> getPageBodyText(String key) async {
    final data = await getPageSettings(key);
    final nested = _unwrapPayload(data);

    final directContent = _extractString(data, const [
          'content',
          'body',
          'description',
          'value',
          'text',
          'html',
          'markdown',
        ]) ??
        _extractString(nested, const [
          'content',
          'body',
          'description',
          'value',
          'text',
          'html',
          'markdown',
        ]);

    if (directContent != null && directContent.trim().isNotEmpty) {
      return directContent.trim();
    }

    // aboutUs can be a structured object (mission/vision/story/hero/team/stats).
    final structured = _buildStructuredPageText(nested);
    if (structured.isNotEmpty) {
      return structured;
    }

    return '';
  }

  Future<List<String>> getHomeBanners() async {
    final home = await getPageSettings('homeBanners');
    final app = await getPageSettings('appBanners');

    final merged = <String>{
      ..._extractImageUrls(home),
      ..._extractImageUrls(app),
    };

    return merged.toList();
  }

  /// Get branding logo URL
  Future<String?> getBrandingLogo() async {
    try {
      final branding = await getPageSettings('branding');
      final data = _unwrapPayload(branding);

      // Try to get logos array
      final logos = data['logos'];
      if (logos is List && logos.isNotEmpty) {
        final firstLogo = _toMap(logos[0]);
        if (firstLogo != null) {
          final url = firstLogo['url'];
          if (url is String && url.trim().isNotEmpty) {
            return url.trim();
          }
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Get onboarding banners as structured data
  Future<List<Map<String, dynamic>>> getOnboardingBanners() async {
    try {
      final home = await getPageSettings('homeBanners');
      final banners = <Map<String, dynamic>>[];

      final directItems = home['data'];
      final fallbackPayload = _unwrapPayload(home);
      final items = directItems is List
          ? directItems
          : fallbackPayload['items'] is List
              ? fallbackPayload['items'] as List
              : fallbackPayload['data'] is List
                  ? fallbackPayload['data'] as List
                  : const [];

      for (final item in items) {
        final banner = _toMap(item);
        if (banner != null) {
          banners.add(banner);
        }
      }

      return banners;
    } catch (_) {
      return [];
    }
  }

  List<String> _extractImageUrls(Map<String, dynamic> source) {
    final urls = <String>[];

    void collect(dynamic value) {
      if (value is String && value.trim().isNotEmpty) {
        final normalized = value.trim();
        if (normalized.startsWith('http://') || normalized.startsWith('https://')) {
          urls.add(normalized);
        }
        return;
      }

      if (value is List) {
        for (final item in value) {
          collect(item);
        }
        return;
      }

      final map = _toMap(value);
      if (map == null) {
        return;
      }

      for (final key in const [
        'url',
        'image',
        'imageUrl',
        'thumbnail',
        'banner',
        'mobileImage',
        'desktopImage',
      ]) {
        collect(map[key]);
      }

      collect(map['banners']);
      collect(map['items']);
      collect(map['data']);
      collect(map['result']);
    }

    collect(source);
    return urls;
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic> source) {
    return _toMap(source['data']) ??
        _toMap(source['result']) ??
        _toMap(source['settings']) ??
        _toMap(source['setting']) ??
        source;
  }

  String _buildStructuredPageText(Map<String, dynamic> payload) {
    final parts = <String>[];

    final heroTitle = (payload['heroTitle'] ?? '').toString().trim();
    final heroDescription = (payload['heroDescription'] ?? '').toString().trim();
    if (heroTitle.isNotEmpty) {
      parts.add('## $heroTitle');
    }
    if (heroDescription.isNotEmpty) {
      parts.add(heroDescription);
    }

    for (final key in const ['mission', 'vision', 'story']) {
      final section = _toMap(payload[key]);
      if (section == null) {
        continue;
      }
      final title = (section['title'] ?? '').toString().trim();
      final description = (section['description'] ?? section['content'] ?? '')
          .toString()
          .trim();
      if (title.isNotEmpty) {
        parts.add('## $title');
      }
      if (description.isNotEmpty) {
        parts.add(description);
      }
    }

    final team = payload['team'];
    if (team is List && team.isNotEmpty) {
      final members = <String>[];
      for (final entry in team) {
        final map = _toMap(entry);
        if (map == null) continue;
        final name = (map['name'] ?? '').toString().trim();
        final role = (map['role'] ?? '').toString().trim();
        if (name.isEmpty && role.isEmpty) continue;
        members.add(role.isEmpty ? '- $name' : '- $name - $role');
      }
      if (members.isNotEmpty) {
        parts.add('## Team');
        parts.add(members.join('\n'));
      }
    }

    final stats = payload['stats'];
    if (stats is List && stats.isNotEmpty) {
      final rows = <String>[];
      for (final entry in stats) {
        final map = _toMap(entry);
        if (map == null) continue;
        final label = (map['label'] ?? '').toString().trim();
        final value = (map['value'] ?? '').toString().trim();
        if (label.isEmpty && value.isEmpty) continue;
        rows.add('- ${label.isEmpty ? 'Item' : label}: $value');
      }
      if (rows.isNotEmpty) {
        parts.add('## Stats');
        parts.add(rows.join('\n'));
      }
    }

    return parts.where((part) => part.trim().isNotEmpty).join('\n\n').trim();
  }

  String? _extractString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  Map<String, dynamic>? _toMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return value.map((key, item) => MapEntry(key.toString(), item));
    }
    return null;
  }
}

