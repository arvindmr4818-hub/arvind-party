import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class GiftsController extends GetxController {
  final gifts = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadGifts();
  }

  Future<void> loadGifts() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getGifts();
      gifts.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[GiftsController] loadGifts error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addGift(Map<String, dynamic> giftData) async {
    try {
      await AdminApi.to.addGift(giftData);
      await loadGifts();
      Get.snackbar(
        'Success',
        'Gift added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add gift',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> deleteGift(String giftId) async {
    try {
      await AdminApi.to.deleteGift(giftId);
      await loadGifts();
      Get.snackbar(
        'Success',
        'Gift deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete gift',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }
}