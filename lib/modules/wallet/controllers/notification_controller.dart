import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/notification_model.dart';

class NotificationController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ── Reactive State Variables ───────────────────────────────────
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

  // 🌐 REAL TIME API: Database aur Cache se data sync karna
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      
      // Local cache storage data loading first for speed optimization
      final cached = _storage.read<List>('notifications') ?? [];
      final list = cached.map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e))).toList();
      notifications.assignAll(list);
      _updateUnreadCount();

      // Real Node.js Route API call: /notifications?filter=all
      final response = await _api.get('/notifications', query: {'filter': filter.value});
      
      if (response is Map && response['success'] == true) {
        final List<dynamic> serverData = response['data'] ?? [];
        final newList = serverData
            .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
            .toList();
            
        notifications.assignAll(newList);
        // Persisting in local device storage
        _storage.write('notifications', newList.map((n) => n.toJson()).toList());
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error loading notifications from backend: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  // 📥 REAL TIME API: Mark a single notification as read in database
  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.post('/notifications/$notificationId/read', body: {});
    } catch (e) {
      debugPrint('Failed to send read update state to backend: $e');
    }
    
    final list = notifications.map((n) {
      if (n.id == notificationId) {
        return AppNotification(
          id: n.id, title: n.title, body: n.body, type: n.type,
          senderId: n.senderId, senderName: n.senderName,
          senderAvatar: n.senderAvatar, targetId: n.targetId,
          isRead: true, createdAt: n.createdAt, data: n.data,
        );
      }
      return n;
    }).toList();
    
    notifications.assignAll(list);
    _storage.write('notifications', list.map((n) => n.toJson()).toList());
    _updateUnreadCount();
  }

  // 🧹 REAL TIME API: Bulk updates read execution frame
  Future<void> markAllAsRead() async {
    if (notifications.isEmpty) return;
    try {
      await _api.post('/notifications/read-all', body: {});
    } catch (e) {
      debugPrint('Failed to sync bulk operations on server: $e');
    }
    
    final list = notifications.map((n) => AppNotification(
      id: n.id, title: n.title, body: n.body, type: n.type,
      senderId: n.senderId, senderName: n.senderName,
      senderAvatar: n.senderAvatar, targetId: n.targetId,
      isRead: true, createdAt: n.createdAt, data: n.data,
    )).toList();
    
    notifications.assignAll(list);
    _storage.write('notifications', list.map((n) => n.toJson()).toList());
    unreadCount.value = 0;
  }

  // 🗑️ REAL TIME API: Delete record entry from MongoDB
  Future<void> deleteNotification(String id) async {
    try {
      await _api.delete('/notifications/$id');
      notifications.removeWhere((n) => n.id == id);
      _storage.write('notifications', notifications.map((n) => n.toJson()).toList());
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Failed to delete user notification reference: $e');
    }
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