import 'package:care_life_touch/app/modules/notification/views/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/values/app_colors.dart';
import '../../../global_widgets/primary_appbar.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PrimaryAppBar(
        title: 'Notifications',
        showBackButton: true,
        onBackPressed: () => Get.back(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return _buildEmptyState();
        }

        return _buildNotificationList();
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty illustration
            Image.asset(
              'assets/images/ic_no_notification.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Notifications Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have no notifications right now.\nCome back later',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary.withValues(alpha: 0.6),
                height: 1.43,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList() {
    final grouped = controller.groupedNotifications;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: grouped.length,
      itemBuilder: (context, groupIndex) {
        final entry = grouped.entries.elementAt(groupIndex);
        final dateLabel = entry.key;
        final items = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.43,
                    ),
                  ),
                  if (dateLabel == 'Today' && controller.unreadCount > 0)
                    GestureDetector(
                      onTap: controller.markAllAsRead,
                      child: const Text(
                        'Mark All As Read',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.primary,
                          height: 1.43,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Notification items
            ...items.map((notification) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NotificationItem(
                notification: notification,
                onTap: () {
                  controller.markAsRead(notification.id);
                  // Handle notification tap action
                },
                onDelete: () {
                  controller.deleteNotification(notification.id);
                  Get.snackbar(
                    'Deleted',
                    'Notification removed',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(16),
                  );
                },
              ),
            )),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}






