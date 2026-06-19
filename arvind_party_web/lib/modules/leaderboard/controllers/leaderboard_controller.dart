import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';

class LeaderboardController extends GetxController {
  final entries = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadLeaderboard();
  }

  Future<void> loadLeaderboard() async {
    isLoading.value = true;
    try {
      final result = await AdminApi.to.getLeaderboard();
      entries.value = result.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('[LeaderboardController] loadLeaderboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetLeaderboard() async {
    try {
      await AdminApi.to.resetLeaderboard();
      await loadLeaderboard();
      Get.snackbar('Success', 'Leaderboard reset',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('Error', 'Failed to reset leaderboard',
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white);
    }
  }
}