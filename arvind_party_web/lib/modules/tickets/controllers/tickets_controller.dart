import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class TicketsController extends GetxController {
  final tickets = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final replyCtrl = TextEditingController();
  final selectedTicket = Rx<Map<String, dynamic>?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTickets();
  }

  @override
  void onClose() {
    replyCtrl.dispose();
    super.onClose();
  }

  Future<void> loadTickets() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getSupportTickets();
      tickets.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[TicketsController] loadTickets error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> replyToTicket(String ticketId) async {
    if (replyCtrl.text.trim().isEmpty) return;
    try {
      await AdminApi.to.replyToTicket(ticketId, replyCtrl.text.trim());
      replyCtrl.clear();
      await loadTickets();
      Get.snackbar('Success', 'Reply sent',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reply',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}