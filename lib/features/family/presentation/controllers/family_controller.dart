// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/controllers/family_controller.dart
// ARVIND PARTY - FAMILY CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class FamilyController extends GetxController {
  final isLoading = false.obs;
  final families = <Map<String, dynamic>>[].obs;
  final selectedFamily = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchFamilies();
  }

  Future<void> fetchFamilies() async {
    try {
      isLoading.value = true;
      // TODO: FamilyRepository().fetchFamilies();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load families');
    } finally {
      isLoading.value = false;
    }
  }
}