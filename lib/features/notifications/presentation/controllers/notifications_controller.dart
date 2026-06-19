// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/notifications/presentation/controllers/notifications_controller.dart
// ARVIND PARTY - NOTIFICATIONS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final isLoading = false.obs;
  final notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      isLoading.value = true;
      // TODO: NotificationsRepository().fetchNotifications();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load notifications');
    } finally {
      isLoading.value = false;
    }
  }

  void markAsRead(String notificationId) {
    // TODO: NotificationsRepository().markAsRead(notificationId);
  }
}