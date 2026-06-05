import 'package:get/get.dart';
import '../models/family_event_model.dart';

class FamilyEventController extends GetxController {
  final upcomingEvents = <FamilyEventModel>[].obs;
  final isProcessing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFamilyEvents();
  }

  void fetchFamilyEvents() {
    upcomingEvents.assignAll([
      FamilyEventModel(
        eventId: "ev_01",
        familyId: "fam_arvind_01",
        title: "Weekend Sound Clash 🎵",
        description:
            "Official internal PK competition matching streamers streams.",
        banner:
            "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=500&q=80",
        scheduledTime: DateTime.now().add(const Duration(days: 2)),
        targetRoomId: "room_lucknow_99",
        status: FamilyEventStatus.upcoming,
        attendeesCount: 24,
      ),
    ]);
  }

  Future<void> dispatchNewEvent(FamilyEventModel newEvent) async {
    isProcessing.value = true;
    await Future.delayed(
        const Duration(milliseconds: 800)); // Server lag simulation
    upcomingEvents.insert(0, newEvent);
    isProcessing.value = false;
    Get.snackbar("Scheduler", "Family internal event timeline active.");
    Get.back();
  }
}
