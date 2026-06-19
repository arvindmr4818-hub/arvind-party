import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class BansController extends GetxController {
  final bans = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  // Create ban form controllers
  final banUserIdCtrl = TextEditingController();
  final banTypeCtrl = TextEditingController(text: 'user');
  final banReasonCtrl = TextEditingController();
  final banDurationCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadBans();
  }

  @override
  void onClose() {
    banUserIdCtrl.dispose();
    banTypeCtrl.dispose();
    banReasonCtrl.dispose();
    banDurationCtrl.dispose();
    super.onClose();
  }

  Future<void> loadBans() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getBans();
      bans.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[BansController] loadBans error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBan() async {
    try {
      await AdminApi.to.createBan({
        'user_id': banUserIdCtrl.text.trim(),
        'type': banTypeCtrl.text.trim(),
        'reason': banReasonCtrl.text.trim(),
        'duration': banDurationCtrl.text.trim(),
      });
      await loadBans();
      banUserIdCtrl.clear();
      banReasonCtrl.clear();
      banDurationCtrl.clear();
      Get.snackbar('Success', 'Ban applied successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to apply ban',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> liftBan(String banId) async {
    try {
      await AdminApi.to.liftBan(banId);
      await loadBans();
      Get.snackbar('Success', 'Ban lifted',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to lift ban',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}