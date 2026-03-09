import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  void loadNotifications() {
    isLoading.value = true;

    // Demo data
    notifications.value = [
      NotificationModel(
        id: '1',
        title: 'New Arrivals Just Dropped!',
        message: 'Be the first to shop the latest styles. Check out our new arrivals now!',
        type: 'promotion',
        date: DateTime.now(),
        isRead: false,
      ),
      NotificationModel(
        id: '2',
        title: 'Exclusive Offer Just for You!',
        message: 'Enjoy 10% off on your next purchase! Tap to redeem your exclusive discount.',
        type: 'promotion',
        date: DateTime.now(),
        isRead: false,
      ),
      NotificationModel(
        id: '3',
        title: 'Item Back in Stock!',
        message: 'Good news! The item you wanted is back. Hurry before it\'s gone again!',
        type: 'stock',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '4',
        title: 'Complete Your Look',
        message: 'Add the perfect finishing touches. Browse recommended accessories just for you.',
        type: 'general',
        date: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
      ),
      NotificationModel(
        id: '5',
        title: 'Item Back in Stock!',
        message: 'Good news! The item you wanted is back. Hurry before it\'s gone again!',
        type: 'stock',
        date: DateTime(2026, 2, 15),
        isRead: true,
      ),
      NotificationModel(
        id: '6',
        title: 'Complete Your Look',
        message: 'Add the perfect finishing touches. Browse recommended accessories just for you.',
        type: 'general',
        date: DateTime(2026, 2, 15),
        isRead: true,
      ),
    ];

    isLoading.value = false;
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

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
    }
  }

  void markAllAsRead() {
    notifications.value = notifications.map((n) => n.copyWith(isRead: true)).toList();
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;
}

