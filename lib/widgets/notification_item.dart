import 'package:flutter/material.dart';
import '../models/notification_data.dart';

class NotificationItem extends StatelessWidget {
  final NotificationData notification;
  final Color cardColor;
  final Color textColor;
  final Color secondaryTextColor;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.cardColor,
    required this.textColor,
    required this.secondaryTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: notification.color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            notification.icon,
            color: notification.color,
            size: 24,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight:
                    notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notification.timeString,
              style: TextStyle(
                color: secondaryTextColor.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          // You can mark as read or navigate to detail here
        },
      ),
    );
  }
}
