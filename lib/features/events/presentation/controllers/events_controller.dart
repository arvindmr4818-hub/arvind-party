// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/events/presentation/controllers/events_controller.dart
// ARVIND PARTY - EVENTS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class EventsController extends GetxController {
  final isLoading = false.obs;
  final events = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchEvents();
  }

  Future<void> fetchEvents() async {
    try {
      isLoading.value = true;
      // TODO: EventsRepository().fetchEvents();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load events');
    } finally {
      isLoading.value = false;
    }
  }
}