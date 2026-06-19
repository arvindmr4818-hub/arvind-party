import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class VipController extends GetxController {
  final plans = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPlans();
  }

  Future<void> loadPlans() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getVipPlans();
      plans.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[VipController] loadPlans error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPlan(Map<String, dynamic> planData) async {
    try {
      await AdminApi.to.createVipPlan(planData);
      await loadPlans();
      Get.snackbar('Success', 'VIP plan created',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create plan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> updatePlan(String id, Map<String, dynamic> planData) async {
    try {
      await AdminApi.to.updateVipPlan(id, planData);
      await loadPlans();
      Get.snackbar('Success', 'VIP plan updated',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update plan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}