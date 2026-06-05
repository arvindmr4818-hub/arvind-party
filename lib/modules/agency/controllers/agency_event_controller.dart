import 'package:get/get.dart';
import '../models/agency_event_model.dart';

class AgencyEventController extends GetxController {
  final institutionalEventsList = <AgencyEventModel>[].obs;
  final isWorking = false.obs;

  @override
  void onInit() {
    super.onInit();
    syncAgencyEventsFeed();
  }

  void syncAgencyEventsFeed() {
    institutionalEventsList.assignAll([
      AgencyEventModel(
        eventId: "ag_ev_990",
        agencyId: "agc_alpha_99",
        title: "National Super Anchor Hunt 🎤",
        description:
            "Mass recruitment drive targeting streaming networks anchors.",
        prizePoolDetails:
            "\$5000 USD Cash allocation split among Top 3 winners",
        startTime: DateTime.now().add(const Duration(days: 1)),
        endTime: DateTime.now().add(const Duration(days: 7)),
        participatingHostsCount: 45,
        cumulativeEventPoints: 124500.00,
      ),
    ]);
  }
}
