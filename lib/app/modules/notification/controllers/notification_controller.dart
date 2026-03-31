import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationController extends GetxController {
  NotificationController({NotificationRepository? notificationRepository})
      : _notificationRepository =
            notificationRepository ?? Get.find<NotificationRepository>();

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final NotificationRepository _notificationRepository;

  bool _didAutoMarkOnView = false;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  @override
  void onReady() {
    super.onReady();
    _autoMarkAllOnView();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final items = await _notificationRepository.getBuyerNotifications();
      notifications.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, List<NotificationModel>> get groupedNotifications {
    final Map<String, List<NotificationModel>> grouped = {
      'Today': [],
      'Yesterday': [],
    };

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var notification in notifications) {
      final notifDate = DateTime(
        notification.date.year,
        notification.date.month,
        notification.date.day,
      );

      if (notifDate == today) {
        grouped['Today']!.add(notification);
      } else if (notifDate == yesterday) {
        grouped['Yesterday']!.add(notification);
      } else {
        final key = _formatDate(notification.date);
        if (!grouped.containsKey(key)) {
          grouped[key] = [];
        }
        grouped[key]!.add(notification);
      }
    }

    // Remove empty groups
    grouped.removeWhere((key, value) => value.isEmpty);

    return grouped;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> markAsRead(String id) async {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
    }

    try {
      await _notificationRepository.markNotificationRead(id);
    } catch (_) {
      // Keep optimistic UI update.
    }
  }

  Future<void> markAllAsRead() async {
    notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();

    try {
      await _notificationRepository.markAllNotificationsRead();
    } catch (_) {
      // Keep optimistic UI update.
    }
  }

  Future<void> deleteNotification(String id) async {
    notifications.removeWhere((n) => n.id == id);

    try {
      await _notificationRepository.deleteNotification(id);
    } catch (_) {
      // Keep optimistic UI update.
    }
  }

  Future<void> _autoMarkAllOnView() async {
    if (_didAutoMarkOnView) {
      return;
    }
    _didAutoMarkOnView = true;

    if (isLoading.value) {
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 120));
        return isLoading.value;
      });
    }

    if (notifications.any((n) => !n.isRead)) {
      await markAllAsRead();
    }
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

