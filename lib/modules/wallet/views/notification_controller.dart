import 'package:get/get.dart';
import '../models/notification_model.dart';

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final notifications = <AppNotification>[].obs;

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  void _loadNotifications() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800)); // Fake API delay

    notifications.assignAll([
      AppNotification(
        id: 'n1',
        title: 'System Update',
        message: 'Welcome to Arvind Party! Enjoy your stay.',
        type: 'system',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
      ),
      AppNotification(
        id: 'n2',
        title: 'New Follower',
        message: 'Rahul Star started following you.',
        type: 'follow',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        avatarUrl: 'https://picsum.photos/seed/n2/100',
      ),
      AppNotification(
        id: 'n3',
        title: 'Gift Received',
        message: 'Priya sent you a Ferrari Mount!',
        type: 'gift',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        avatarUrl: 'https://picsum.photos/seed/n3/100',
      ),
    ]);

    isLoading.value = false;
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      // TODO: Call API -> apiService.markNotificationRead(id);
    }
  }

  void markAllAsRead() {
    for (int i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    // TODO: Call API -> apiService.markAllNotificationsRead();
  }
}
