// lib/modules/wallet/views/notification_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/notification_model.dart';

class NotificationController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  final isLoading = false.obs;
  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;
  final filter = 'all'.obs;

  static const filters = ['all', 'follow', 'gift', 'room_invite', 'system', 'agency', 'family'];

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      final cached = _storage.read<List>('notifications') ?? [];
      final list = cached.map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))).toList();
      notifications.assignAll(list);
      _updateUnreadCount();

      final response = await _api.get('/notifications', query: {'filter': filter.value});
      if (response is Map && response['success'] == true) {
        final newList = (response['data'] as List? ?? [])
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        notifications.assignAll(newList);
        _storage.write('notifications', newList.map((n) => n.toJson()).toList());
        _updateUnreadCount();
      } else if (notifications.isEmpty) {
        notifications.assignAll(_demoNotifications());
      }
    } catch (_) {
      if (notifications.isEmpty) {
        notifications.assignAll(_demoNotifications());
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  List<AppNotification> _demoNotifications() {
    return [
      AppNotification(id: 'n1', title: 'Welcome to Arvind Party!', body: 'Get started by exploring live rooms.', type: 'system', isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 1))),
      AppNotification(id: 'n2', title: 'New Follower', body: 'John Doe started following you.', type: 'follow', senderId: 'u1', senderName: 'John Doe', senderAvatar: '', isRead: false, createdAt: DateTime.now().subtract(const Duration(hours: 3))),
      AppNotification(id: 'n3', title: 'You received a gift!', body: 'Someone sent you a Firework', type: 'gift', senderId: 'u2', senderName: 'Jane', senderAvatar: '', isRead: true, createdAt: DateTime.now().subtract(const Duration(hours: 12))),
    ];
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.post('/notifications/$notificationId/read');
    } catch (_) {}
    final list = notifications.map((n) {
      if (n.id == notificationId) {
        return AppNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          type: n.type,
          senderId: n.senderId,
          senderName: n.senderName,
          senderAvatar: n.senderAvatar,
          targetId: n.targetId,
          isRead: true,
          createdAt: n.createdAt,
          data: n.data,
        );
      }
      return n;
    }).toList();
    notifications.assignAll(list);
    _updateUnreadCount();
  }

  Future<void> markAllAsRead() async {
    try {
      await _api.post('/notifications/read-all');
    } catch (_) {}
    final list = notifications.map((n) => AppNotification(
      id: n.id,
      title: n.title,
      body: n.body,
      type: n.type,
      senderId: n.senderId,
      senderName: n.senderName,
      senderAvatar: n.senderAvatar,
      targetId: n.targetId,
      isRead: true,
      createdAt: n.createdAt,
      data: n.data,
    )).toList();
    notifications.assignAll(list);
    unreadCount.value = 0;
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _api.delete('/notifications/$id');
    } catch (_) {}
    notifications.removeWhere((n) => n.id == id);
    _updateUnreadCount();
  }

  List<AppNotification> get filteredNotifications {
    if (filter.value == 'all') return notifications.toList();
    return notifications.where((n) => n.type == filter.value).toList();
  }

  void setFilter(String f) {
    filter.value = f;
    loadNotifications();
  }
}
