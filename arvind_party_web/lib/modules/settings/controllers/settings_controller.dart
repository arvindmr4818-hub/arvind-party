import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class SettingsController extends GetxController {
  final settings = <String, dynamic>{}.obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final response = await AdminApi.to.getSettings();
      if (response['data'] is Map) {
        settings.assignAll(response['data'] as Map<String, dynamic>);
      } else {
        settings.assignAll(response);
      }
    } catch (e) {
      debugPrint('[SettingsController] loadSettings error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings(Map<String, dynamic> newSettings) async {
    isSaving.value = true;
    try {
      await AdminApi.to.updateSettings(newSettings);
      settings.assignAll(newSettings);
      Get.snackbar('Success', 'Settings saved',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to save settings',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }
}