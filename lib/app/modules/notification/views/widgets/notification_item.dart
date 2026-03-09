import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/values/app_colors.dart';
import '../../../../data/models/notification_model.dart';


class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  Color _getIconBackgroundColor() {
    switch (notification.type) {
      case 'promotion':
        return const Color(0xFFECFDF7);
      case 'stock':
        return const Color(0xFFFEF2F3);
      case 'order':
        return const Color(0xFFECFDF7);
      case 'general':
        return const Color(0xFFFEF2F3);
      default:
        return const Color(0xFFF6F6F6);
    }
  }

  IconData _getIcon() {
    switch (notification.type) {
      case 'promotion':
        return Icons.shopping_bag_outlined;
      case 'stock':
        return Icons.star_border;
      case 'order':
        return Icons.inventory_2_outlined;
      case 'general':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(notification.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,
        children: [
          CustomSlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: Colors.transparent,
            padding: EdgeInsets.zero,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.border),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFEF4444),
                size: 24,
              ),
            ),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getIconBackgroundColor(),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getIcon(),
                  size: 24,
                  color: AppColors.textPrimary.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 12),
              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary.withOpacity(0.7),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


