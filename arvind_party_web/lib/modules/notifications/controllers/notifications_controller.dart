import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class NotificationsController extends GetxController {
  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final targetAudience = ''.obs;
  final isSending = false.obs;
  final history = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getNotificationHistory();
      history.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[NotificationsController] loadHistory error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendNotification() async {
    if (titleCtrl.text.trim().isEmpty || messageCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Title and message are required',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
      return;
    }

    isSending.value = true;
    try {
      await AdminApi.to.sendNotification({
        'title': titleCtrl.text.trim(),
        'message': messageCtrl.text.trim(),
        'target_audience': targetAudience.value.isEmpty ? null : targetAudience.value,
      });
      await loadHistory();
      titleCtrl.clear();
      messageCtrl.clear();
      Get.snackbar('Success', 'Notification sent',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    } finally {
      isSending.value = false;
    }
  }
}