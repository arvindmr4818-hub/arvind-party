import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class AgencyController extends GetxController {
  final agencies = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadAgencies();
  }

  Future<void> loadAgencies() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getAgencies();
      agencies.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[AgencyController] loadAgencies error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveAgency(String id) async {
    try {
      await AdminApi.to.approveAgency(id);
      await loadAgencies();
      Get.snackbar('Success', 'Agency approved',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve agency',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> revokeAgency(String id) async {
    try {
      await AdminApi.to.revokeAgency(id);
      await loadAgencies();
      Get.snackbar('Success', 'Agency access revoked',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to revoke agency',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}