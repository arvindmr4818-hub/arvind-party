import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class ReportsController extends GetxController {
  final reports = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getReports();
      reports.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[ReportsController] loadReports error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resolveReport(String id) async {
    try {
      await AdminApi.to.resolveReport(id);
      await loadReports();
      Get.snackbar('Success', 'Report resolved',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to resolve report',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> deleteReport(String id) async {
    try {
      await AdminApi.to.deleteReport(id);
      await loadReports();
      Get.snackbar('Success', 'Report deleted',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete report',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}