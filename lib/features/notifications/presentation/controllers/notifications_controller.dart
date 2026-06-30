import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../data/notification_repository.dart';

class NotificationsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final notifications = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final unreadCount = 0.obs;

  @override
  void onInit() { super.onInit(); load(); }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/notifications');
      if (res['success'] == true) {
        notifications.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
        unreadCount.value = notifications.where((n) => n['isRead'] != true).length;
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> markAllRead() async {
    try {
      await _api.put('/notifications/read-all', {});
      for (var n in notifications) { n['isRead'] = true; }
      notifications.refresh();
      unreadCount.value = 0;
    } catch (_) {}
  }

  Future<void> deleteNotification(String? id) async {
    if (id == null) return;
    notifications.removeWhere((n) => n['_id'] == id);
    try { await _api.delete('/notifications/$id'); } catch (_) {}
  }

  void onNotificationTap(Map<String, dynamic> n) {
    // Mark as read
    final idx = notifications.indexWhere((x) => x['_id'] == n['_id']);
    if (idx != -1) {
      notifications[idx]['isRead'] = true;
      notifications.refresh();
      unreadCount.value = notifications.where((n) => n['isRead'] != true).length;
    }
    _api.put('/notifications/${n['_id']}/read', {});

    // Navigate based on type
    switch (n['type']) {
      case 'gift': break;
      case 'follow': Get.toNamed('/profile', arguments: {'userId': n['data']?['fromUserId']}); break;
      case 'room': Get.toNamed('/room', arguments: {'roomId': n['data']?['roomId']}); break;
      default: break;
    }
  }
}
