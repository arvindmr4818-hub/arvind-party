import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(NotificationsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF12111F),
        title: const Text('Notifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: Get.back),
        actions: [
          TextButton(
            onPressed: ctrl.markAllRead,
            child: const Text('Mark all read', style: TextStyle(color: Color(0xFFFF8906), fontSize: 12)),
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        if (ctrl.notifications.isEmpty) return const Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, color: Colors.white24, size: 64),
            SizedBox(height: 16),
            Text('No notifications yet', style: TextStyle(color: Colors.white54, fontSize: 16)),
          ],
        ));
        return RefreshIndicator(
          color: const Color(0xFFFF8906),
          onRefresh: ctrl.load,
          child: ListView.builder(
            itemCount: ctrl.notifications.length,
            itemBuilder: (_, i) {
              final n = ctrl.notifications[i];
              final isRead = n['isRead'] == true;
              return Dismissible(
                key: Key(n['_id'] ?? i.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => ctrl.deleteNotification(n['_id']),
                child: GestureDetector(
                  onTap: () => ctrl.onNotificationTap(n),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isRead ? Colors.transparent : const Color(0xFFFF8906).withOpacity(0.05),
                      border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
                    ),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Icon
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _iconBg(n['type']),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icon(n['type']), color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(n['title'] ?? '', style: TextStyle(
                          color: Colors.white, fontWeight: isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 3),
                        Text(n['body'] ?? '', style: const TextStyle(color: Color(0xFFB0B0C0), fontSize: 13),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text(_timeAgo(n['createdAt']),
                          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
                      ])),
                      if (!isRead) Container(
                        width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(color: Color(0xFFFF8906), shape: BoxShape.circle),
                      ),
                    ]),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Color _iconBg(String? type) {
    switch (type) {
      case 'gift': return const Color(0xFFFF8906);
      case 'follow': return const Color(0xFF2196F3);
      case 'vip': return const Color(0xFFFFD700);
      case 'system': return const Color(0xFF9C27B0);
      default: return const Color(0xFF4CAF50);
    }
  }

  IconData _icon(String? type) {
    switch (type) {
      case 'gift': return Icons.card_giftcard;
      case 'follow': return Icons.person_add;
      case 'vip': return Icons.star;
      case 'system': return Icons.info;
      default: return Icons.notifications;
    }
  }

  String _timeAgo(dynamic d) {
    if (d == null) return '';
    try {
      final dt = DateTime.parse(d.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }
}
