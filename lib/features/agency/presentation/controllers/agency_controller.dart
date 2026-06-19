// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/controllers/agency_controller.dart
// ARVIND PARTY - AGENCY CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../repositories/agency_repository.dart';

class AgencyController extends GetxController {
  final isLoading = false.obs;
  final agencyData = Rxn<Map<String, dynamic>>();
  final members = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAgencyData();
  }

  Future<void> loadAgencyData() async {
    try {
      isLoading.value = true;
      agencyData.value = await AgencyRepository().fetchData();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final fetchedMembers = await AgencyRepository().fetchMembers();
      members.assignAll(fetchedMembers);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load agency members');
    } finally {
      isLoading.value = false;
    }
  }
}