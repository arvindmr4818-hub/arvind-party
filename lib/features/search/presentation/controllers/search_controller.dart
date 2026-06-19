// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/search/presentation/controllers/search_controller.dart
// ARVIND PARTY - SEARCH CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class SearchController extends GetxController {
  final isLoading = false.obs;
  final query = ''.obs;
  final results = <Map<String, dynamic>>[].obs;

  Future<void> search(String q) async {
    query.value = q;
    if (q.trim().isEmpty) {
      results.clear();
      return;
    }
    try {
      isLoading.value = true;
      // TODO: SearchRepository().search(q);
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (e) {
      Get.snackbar('Error', 'Search failed');
    } finally {
      isLoading.value = false;
    }
  }
}