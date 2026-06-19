import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class EventsController extends GetxController {
  final events = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  // Form fields
  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final rewardCtrl = TextEditingController();
  final startDateCtrl = TextEditingController();
  final endDateCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    rewardCtrl.dispose();
    startDateCtrl.dispose();
    endDateCtrl.dispose();
    super.onClose();
  }

  Future<void> loadEvents() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getEvents();
      events.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[EventsController] loadEvents error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createEvent() async {
    try {
      await AdminApi.to.createEvent({
        'title': titleCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'reward': rewardCtrl.text.trim(),
        'start_date': startDateCtrl.text.trim(),
        'end_date': endDateCtrl.text.trim(),
      });
      await loadEvents();
      _clearForm();
      Get.snackbar('Success', 'Event created',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create event',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> updateEvent(String id) async {
    try {
      await AdminApi.to.updateEvent(id, {
        'title': titleCtrl.text.trim(),
        'description': descriptionCtrl.text.trim(),
        'reward': rewardCtrl.text.trim(),
        'start_date': startDateCtrl.text.trim(),
        'end_date': endDateCtrl.text.trim(),
      });
      await loadEvents();
      _clearForm();
      Get.snackbar('Success', 'Event updated',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update event',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await AdminApi.to.deleteEvent(id);
      await loadEvents();
      Get.snackbar('Success', 'Event deleted',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete event',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  void _clearForm() {
    titleCtrl.clear();
    descriptionCtrl.clear();
    rewardCtrl.clear();
    startDateCtrl.clear();
    endDateCtrl.clear();
  }
}