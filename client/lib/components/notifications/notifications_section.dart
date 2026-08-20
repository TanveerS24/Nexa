import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/notification_item.dart';
import 'notification_card.dart';

class NotificationsSection extends StatelessWidget {
  final List<NotificationItem> notifications;
  final VoidCallback? onViewAllTap;
  final ValueChanged<NotificationItem>? onNotificationTap;

  const NotificationsSection({
    super.key,
    required this.notifications,
    this.onViewAllTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notifications',
                style: AppTextStyles.sectionTitle,
              ),
              GestureDetector(
                onTap: onViewAllTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View all',
                      style: AppTextStyles.viewAll,
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // List of Notification Cards
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notifications.length,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final item = notifications[index];
              return NotificationCard(
                item: item,
                onTap: () => onNotificationTap?.call(item),
              );
            },
          ),
        ],
      ),
    );
  }
}
