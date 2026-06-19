import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class AdminRolesController extends GetxController {
  final roles = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  // Create/Edit form
  final nameCtrl = TextEditingController();
  final permissions = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoles();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    super.onClose();
  }

  Future<void> loadRoles() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getAdminRoles();
      roles.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[AdminRolesController] loadRoles error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createRole() async {
    try {
      await AdminApi.to.createAdminRole({
        'name': nameCtrl.text.trim(),
        'permissions': permissions,
      });
      await loadRoles();
      nameCtrl.clear();
      permissions.clear();
      Get.snackbar('Success', 'Role created',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create role',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }

  Future<void> updateRole(String id) async {
    try {
      await AdminApi.to.updateAdminRole(id, {
        'name': nameCtrl.text.trim(),
        'permissions': permissions,
      });
      await loadRoles();
      Get.snackbar('Success', 'Role updated',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update role',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}