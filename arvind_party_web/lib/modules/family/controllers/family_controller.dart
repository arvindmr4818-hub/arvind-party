import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class FamilyController extends GetxController {
  final families = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadFamilies();
  }

  Future<void> loadFamilies() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getFamilies();
      families.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[FamilyController] loadFamilies error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteFamily(String id) async {
    try {
      await AdminApi.to.deleteFamily(id);
      await loadFamilies();
      Get.snackbar('Success', 'Family deleted',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete family',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}