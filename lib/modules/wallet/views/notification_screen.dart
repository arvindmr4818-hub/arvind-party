import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text('Mark all read',
                style: TextStyle(color: Color(0xFFFF8906))),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_off, size: 64, color: Colors.white38),
                SizedBox(height: 16),
                Text('No notifications yet',
                    style: TextStyle(color: Colors.white54, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];

            IconData iconData;
            Color iconColor;

            switch (notif.type) {
              case 'system':
                iconData = Icons.info;
                iconColor = Colors.blueAccent;
                break;
              case 'follow':
                iconData = Icons.person_add;
                iconColor = Colors.greenAccent;
                break;
              case 'gift':
                iconData = Icons.card_giftcard;
                iconColor = Colors.pinkAccent;
                break;
              default:
                iconData = Icons.notifications;
                iconColor = Colors.white54;
            }

            return InkWell(
              onTap: () => controller.markAsRead(notif.id),
              child: Container(
                color: notif.isRead
                    ? Colors.transparent
                    : const Color(0xFFFF8906).withOpacity(0.05),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (notif.avatarUrl != null)
                      CircleAvatar(
                          backgroundImage: NetworkImage(notif.avatarUrl!),
                          radius: 24)
                    else
                      CircleAvatar(
                          backgroundColor: iconColor.withOpacity(0.2),
                          radius: 24,
                          child: Icon(iconData, color: iconColor)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  child: Text(notif.title,
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: notif.isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          fontSize: 16))),
                              Text(_timeAgo(notif.timestamp),
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(notif.message,
                              style: TextStyle(
                                  color: notif.isRead
                                      ? Colors.white54
                                      : Colors.white70,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                    if (!notif.isRead) ...[
                      const SizedBox(width: 12),
                      Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                              color: Color(0xFFFF8906),
                              shape: BoxShape.circle)),
                    ]
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  String _timeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
