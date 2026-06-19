// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/ranking/presentation/controllers/ranking_controller.dart
// ARVIND PARTY - RANKING CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class RankingController extends GetxController {
  final isLoading = false.obs;
  final rankings = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRankings();
  }

  Future<void> fetchRankings() async {
    try {
      isLoading.value = true;
      // TODO: RankingRepository().fetchRankings();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load rankings');
    } finally {
      isLoading.value = false;
    }
  }
}