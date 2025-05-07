import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { warning, info }

class NotificationData {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final NotificationType type;
  bool isRead;

  NotificationData({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isRead = false,
  });

  // Computed property for icon
  IconData get icon {
    switch (type) {
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info_outline;
    }
  }

  // Computed property for color
  Color get color {
    switch (type) {
      case NotificationType.warning:
        return Colors.red;
      case NotificationType.info:
        return Colors.blue;
    }
  }

  // Time display string
  String get timeString {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }

  // Firestore factory
  factory NotificationData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Log raw Firestore data for debugging
    debugPrint('Firestore document ID: ${doc.id}');
    debugPrint('Raw Firestore data: $data');

    if (data == null) {
      debugPrint('Error: Firestore document data is null for ID: ${doc.id}');
      return NotificationData(
        id: doc.id,
        title: 'Unknown',
        message: 'No data available',
        time: DateTime.now(),
        type: NotificationType.info,
        isRead: false,
      );
    }

    // Map Firestore fields to NotificationData
    // Using provided field names: title, description, createdAt, date, type
    final title = data['title']?.toString() ?? 'Untitled';
    final message = data['description']?.toString() ?? 'No message';
    // Prefer createdAt, fallback to date
    final date = (data['createdAt'] as Timestamp?)?.toDate() ??
        (data['date'] as Timestamp?)?.toDate() ??
        DateTime.now();
    final typeString = data['type']?.toString() ?? 'info';
    final isRead = data['isRead'] as bool? ?? false;

    return NotificationData(
      id: doc.id,
      title: title,
      message: message,
      time: date,
      type: typeString.toLowerCase() == 'warning'
          ? NotificationType.warning
          : NotificationType.info,
      isRead: isRead,
    );
  }

  // Convert to map (for updates)
  Map<String, dynamic> toMap() {
    return {
      'isRead': isRead,
    };
  }
}

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Notifications'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Using correct collection name
        stream: FirebaseFirestore.instance
            .collection('weatherNotifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore stream error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('No documents found in weatherNotifications collection');
            return const Center(child: Text('No notifications found'));
          }

          final notifications = snapshot.data!.docs
              .map((doc) => NotificationData.fromFirestore(doc))
              .toList();

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return NotificationCard(notification: notification);
            },
          );
        },
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationData notification;

  const NotificationCard({Key? key, required this.notification}) : super(key: key);

  Future<void> _markAsRead(String id) async {
    try {
      // Using correct collection name
      await FirebaseFirestore.instance
          .collection('weatherNotifications')
          .doc(id)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: notification.isRead ? Colors.grey[100] : Colors.white,
      child: ListTile(
        leading: Icon(
          notification.icon,
          color: notification.color,
          size: 30,
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              notification.timeString,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        onTap: () {
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
        },
      ),
    );
  }
}