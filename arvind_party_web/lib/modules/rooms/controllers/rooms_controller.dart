import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class RoomsController extends GetxController {
  final rooms = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadRooms();
  }

  Future<void> loadRooms() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getRooms();
      rooms.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[RoomsController] loadRooms error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> closeRoom(String roomId) async {
    try {
      await AdminApi.to.closeRoom(roomId);
      await loadRooms();
      Get.snackbar(
        'Success',
        'Room closed successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to close room',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }
}
