import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class SecurityController extends GetxController {
  final logins = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final ipCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadLogins();
  }

  @override
  void onClose() {
    ipCtrl.dispose();
    reasonCtrl.dispose();
    super.onClose();
  }

  Future<void> loadLogins() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getSecurityLogins();
      logins.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[SecurityController] loadLogins error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> blockIp() async {
    if (ipCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'IP address is required',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
      return;
    }
    try {
      await AdminApi.to.blockIp(ipCtrl.text.trim(), reasonCtrl.text.trim());
      ipCtrl.clear();
      reasonCtrl.clear();
      Get.snackbar('Success', 'IP blocked',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to block IP',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}