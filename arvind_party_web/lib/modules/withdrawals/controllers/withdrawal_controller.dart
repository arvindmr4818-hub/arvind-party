import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class WithdrawalController extends GetxController {
  final withdrawals = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadWithdrawals();
  }

  Future<void> loadWithdrawals() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getWithdrawals();
      withdrawals.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[WithdrawalController] loadWithdrawals error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveWithdrawal(String id) async {
    try {
      await AdminApi.to.approveWithdrawal(id);
      await loadWithdrawals();
      Get.snackbar('Success', 'Withdrawal approved',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve withdrawal',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> rejectWithdrawal(String id, String reason) async {
    try {
      await AdminApi.to.rejectWithdrawal(id, reason);
      await loadWithdrawals();
      Get.snackbar('Success', 'Withdrawal rejected',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject withdrawal',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}