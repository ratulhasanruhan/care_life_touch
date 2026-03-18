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
    final content = _extractString(data, const [
      'content',
      'body',
      'description',
      'value',
      'text',
      'html',
    ]);

    if (content != null) {
      return content;
    }

    final nested = _toMap(data['data']) ?? _toMap(data['result']) ?? data;
    return _extractString(nested, const [
          'content',
          'body',
          'description',
          'value',
          'text',
          'html',
        ]) ??
        '';
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

      for (final key in const ['url', 'image', 'imageUrl', 'thumbnail', 'banner']) {
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

