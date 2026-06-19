// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/notifications/presentation/views/notification_screen.dart
// ARVIND PARTY - NOTIFICATION SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationScreen extends GetView<NotificationsController> {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Text('No notifications', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: Icon(
                  notif['read'] == true ? Icons.notifications_none : Icons.notifications_active,
                  color: const Color(0xFFFF8906),
                ),
                title: Text(notif['title'] ?? '', style: const TextStyle(color: Colors.white)),
                subtitle: Text(notif['body'] ?? '', style: const TextStyle(color: Colors.grey)),
                onTap: () => controller.markAsRead(notif['id'] ?? ''),
              ),
            );
          },
        );
      }),
    );
  }
}