import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class AnnouncementsController extends GetxController {
  final announcements = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isSending = false.obs;

  // Form
  final titleCtrl = TextEditingController();
  final messageCtrl = TextEditingController();
  final targetCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAnnouncements();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    messageCtrl.dispose();
    targetCtrl.dispose();
    super.onClose();
  }

  Future<void> loadAnnouncements() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getAnnouncements();
      announcements.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[AnnouncementsController] loadAnnouncements error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendAnnouncement() async {
    if (titleCtrl.text.trim().isEmpty || messageCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Title and message are required',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
      return;
    }

    isSending.value = true;
    try {
      await AdminApi.to.sendAnnouncement(
        title: titleCtrl.text.trim(),
        message: messageCtrl.text.trim(),
        targetAudience: targetCtrl.text.trim().isNotEmpty
            ? targetCtrl.text.trim()
            : null,
      );
      await loadAnnouncements();
      titleCtrl.clear();
      messageCtrl.clear();
      targetCtrl.clear();
      Get.snackbar('Success', 'Announcement sent',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send announcement',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    } finally {
      isSending.value = false;
    }
  }
}