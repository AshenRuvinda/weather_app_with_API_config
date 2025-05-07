import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/notification_item.dart';
import '../models/notification_data.dart';

class NotificationsPage extends StatefulWidget {
  final bool isDarkMode;

  const NotificationsPage({
    Key? key,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool isLoading = true;

  // Theme colors
  late Color backgroundColor;
  late Color cardColor;
  late Color textColor;
  late Color secondaryTextColor;

  @override
  void initState() {
    super.initState();
    _updateThemeColors();
  }

  @override
  void didUpdateWidget(NotificationsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      _updateThemeColors();
    }
  }

  void _updateThemeColors() {
    setState(() {
      backgroundColor = widget.isDarkMode ? Color(0xFF1E1E2C) : Colors.white;
      cardColor = widget.isDarkMode ? Color(0xFF2C2C3A) : Colors.grey[200]!;
      textColor = widget.isDarkMode ? Colors.white : Colors.black;
      secondaryTextColor = widget.isDarkMode ? Colors.white70 : Colors.black54;
      isLoading = false; // Set isLoading to false after theme is initialized
    });
  }

  void _markAllAsRead() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final notifications = await FirebaseFirestore.instance
          .collection('weatherNotifications')
          .get();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  void _deleteNotification(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('weatherNotifications')
          .doc(id)
          .delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Notifications',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: textColor),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('weatherNotifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            debugPrint('Firestore stream error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          }

          if (snapshot.connectionState == ConnectionState.waiting || isLoading) {
            return Center(child: CircularProgressIndicator(color: textColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            debugPrint('No documents found in weatherNotifications collection');
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs
              .map((doc) {
            final data = doc.data() as Map<String, dynamic>?;
            debugPrint('Firestore document ID: ${doc.id}');
            debugPrint('Raw Firestore data: $data');
            return NotificationData.fromFirestore(doc);
          })
              .toList();

          return _buildNotificationsList(notifications);
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: secondaryTextColor,
          ),
          SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'ll receive notifications about weather alerts and updates here',
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationData> notifications) {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Dismissible(
          key: Key(notification.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            _deleteNotification(notification.id);
          },
          child: NotificationItem(
            notification: notification,
            cardColor: cardColor,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: textColor,
          unselectedItemColor: secondaryTextColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Alerts',
              activeIcon: Icon(Icons.notifications, color: Colors.blueAccent),
            ),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          ],
          currentIndex: 2, // Notifications tab is selected
          onTap: (index) {
            if (index != 2) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}