import 'package:get/get.dart';

import '../models/notification_model.dart';
import '../providers/api_provider.dart';

class NotificationRepository {
  NotificationRepository({ApiProvider? apiProvider})
      : _api = apiProvider ??
            (Get.isRegistered<ApiProvider>()
                ? Get.find<ApiProvider>()
                : Get.put(ApiProvider(), permanent: true));

  final ApiProvider _api;

  Future<List<NotificationModel>> getBuyerNotifications() async {
    final response = await _api.getData('/get-buyer-notifications');
    final list = _extractList(response, preferredKeys: const ['notifications']);
    return list.map(NotificationModel.fromJson).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _api.getData('/get-unread-count');
    final map = _toMap(response) ?? const <String, dynamic>{};
    final data = _toMap(map['data']) ?? map;

    for (final key in const ['unreadCount', 'count', 'total']) {
      final value = data[key];
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
    }

    return 0;
  }

  Future<void> markNotificationRead(String id) async {
    await _api.patchData('/mark-notification-read/$id');
  }

  Future<void> markAllNotificationsRead() async {
    await _api.patchData('/mark-all-notifications-read');
  }

  Future<void> deleteNotification(String id) async {
    await _api.deleteData('/delete-notification/$id');
  }

  List<Map<String, dynamic>> _extractList(
    dynamic response, {
    List<String> preferredKeys = const [],
  }) {
    final root = _toMap(response);
    if (root == null) {
      return const [];
    }

    final candidates = <dynamic>[
      for (final key in preferredKeys) root[key],
      root['data'],
      root['items'],
      root['result'],
      root,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate.map(_toMap).whereType<Map<String, dynamic>>().toList();
      }

      final nested = _toMap(candidate);
      if (nested != null) {
        final nestedList = nested['notifications'] ?? nested['items'] ?? nested['data'];
        if (nestedList is List) {
          return nestedList
              .map(_toMap)
              .whereType<Map<String, dynamic>>()
              .toList();
        }
      }
    }

    return const [];
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

