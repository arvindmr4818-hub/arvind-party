import 'package:get/get.dart';
import '../models/agency_model.dart';
import '../models/agency_member_model.dart';

class AgencyController extends GetxController {
  final currentAgency = Rxn<AgencyModel>();
  final agencyHostsList = <AgencyMemberModel>[].obs;
  final globalAgencyRankings = <AgencyModel>[].obs;

  final isLoading = false.obs;
  final rankingTimeline = "Monthly".obs; // Weekly, Monthly, Lifetime

  @override
  void onInit() {
    super.onInit();
    fetchAgencyProfileData();
    fetchGlobalAgencyStandings("Monthly");
  }

  // 1. Core Profile Fetching Engine
  Future<void> fetchAgencyProfileData() async {
    try {
      isLoading.value = true;
      await Future.delayed(
          const Duration(milliseconds: 600)); // Network throttle mimic

      currentAgency.value = const AgencyModel(
        id: "agc_alpha_99",
        name: "Skylark Talent Network",
        logo:
            "https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=150&q=80",
        banner:
            "https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=600&q=80",
        level: 8,
        totalHosts: 124,
        monthlyRevenue: 14500.50,
        lifetimeRevenue: 284000.00,
        ownerId: "own_777",
        ownerName: "Director Arvind Kumar",
        isOpenForRecruitment: true,
      );

      // Seed host array metadata tracking logs
      agencyHostsList.assignAll([
        AgencyMemberModel(
          hostId: "host_01",
          username: "Sonia Sharma (Live 🎵)",
          avatar: "https://picsum.photos/160",
          level: 28,
          country: "India",
          role: AgencyRole.host,
          monthlyRevenueGenerated: 4500.00,
          targetProgressPercentage: 90.0,
          onlineHoursThisMonth: 44.5,
          contractSignedAt: DateTime.now().subtract(const Duration(days: 90)),
          isCurrentlyBroadcasting: true,
        ),
        AgencyMemberModel(
          hostId: "host_02",
          username: "Rohan Kapoor",
          avatar: "https://picsum.photos/161",
          level: 15,
          country: "India",
          role: AgencyRole.trainee,
          monthlyRevenueGenerated: 1200.00,
          targetProgressPercentage: 40.0,
          onlineHoursThisMonth: 18.2,
          contractSignedAt: DateTime.now().subtract(const Duration(days: 15)),
          isCurrentlyBroadcasting: false,
        ),
      ]);
    } catch (e) {
      Get.snackbar("Agency Core", "Failed to resolve agency profiles: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. High-Speed Leaderboards Standings Filter
  void fetchGlobalAgencyStandings(String timeline) {
    rankingTimeline.value = timeline;
    globalAgencyRankings.assignAll([
      const AgencyModel(
          id: "ag_1",
          name: "Skylark Talent Network",
          logo: "https://picsum.photos/70",
          banner: "",
          level: 8,
          totalHosts: 124,
          monthlyRevenue: 14500.50,
          lifetimeRevenue: 284000,
          ownerId: "1",
          ownerName: "Arvind"),
      const AgencyModel(
          id: "ag_2",
          name: "Nexus Media Stream",
          logo: "https://picsum.photos/71",
          banner: "",
          level: 7,
          totalHosts: 98,
          monthlyRevenue: 11200.00,
          lifetimeRevenue: 195000,
          ownerId: "2",
          ownerName: "Vikram"),
      const AgencyModel(
          id: "ag_3",
          name: "Vibe Records Inc",
          logo: "https://picsum.photos/72",
          banner: "",
          level: 5,
          totalHosts: 60,
          monthlyRevenue: 8900.00,
          lifetimeRevenue: 110000,
          ownerId: "3",
          ownerName: "Zayn"),
    ]);
  }

  // 3. Functional Mutations Wrappers
  Future<void> launchNewAgencyHub(
      {required String title, required String terms}) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    Get.snackbar("Registry",
        "Professional Corporate Agency Profile established safely.");
    isLoading.value = false;
    Get.back();
  }

  void patchRecruitmentStatus(bool isOpen) {
    if (currentAgency.value != null) {
      currentAgency.value =
          currentAgency.value!.copyWith(isOpenForRecruitment: isOpen);
      Get.snackbar(
          "System Configuration", "Recruitment pipelines flags toggled.");
    }
  }
}
