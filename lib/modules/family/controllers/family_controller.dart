import 'package:get/get.dart';
import '../models/family_model.dart';
import '../models/family_member_model.dart';

class FamilyController extends GetxController {
  final currentFamily = Rxn<FamilyModel>();
  final familyMembersList = <FamilyMemberModel>[].obs;
  final globalFamilyRankings = <FamilyModel>[].obs;

  final isLoading = false.obs;
  final selectedRankingTimeline = "Daily".obs; // Daily, Weekly, Monthly

  @override
  void onInit() {
    super.onInit();
    loadUserFamilyDetails();
    loadFamilyRankings("Daily");
  }

  // 1. Fetch Target User Family Framework Snapshots
  Future<void> loadUserFamilyDetails() async {
    try {
      isLoading.value = true;
      await Future.delayed(
          const Duration(milliseconds: 600)); // Network simulation

      currentFamily.value = const FamilyModel(
        id: "fam_arvind_01",
        name: "Lucknow Warriors",
        logo:
            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&q=80",
        banner:
            "https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=600&q=80",
        description:
            "Coding giants and non-stop voice chat streams powerhouse.",
        notice:
            "Family War is scheduled for Sunday! Everyone collect free coins badges 🚀",
        level: 12,
        points: 84500,
        currentExp: 4500,
        nextLevelExp: 10000,
        membersCount: 42,
        maxMembersLimit: 150,
        ownerId: "me_123",
        ownerName: "Arvind Kumar",
      );

      // Populate member array mocks
      familyMembersList.assignAll([
        FamilyMemberModel(
          userId: "me_123",
          name: "Arvind Kumar",
          avatar: "https://picsum.photos/150",
          userLevel: 45,
          role: FamilyRole.owner,
          dynamicContribution: 25000,
          todayContribution: 450,
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
          isOnline: true,
        ),
        FamilyMemberModel(
          userId: "user_dev_99",
          name: "Rohan Alpha",
          avatar: "https://picsum.photos/151",
          userLevel: 32,
          role: FamilyRole.coOwner,
          dynamicContribution: 18000,
          todayContribution: 120,
          joinedAt: DateTime.now().subtract(const Duration(days: 20)),
          isOnline: true,
        ),
      ]);
    } catch (e) {
      Get.snackbar("Family Error", "Failed to compile family node values: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. Dynamic Rankings Catalog Filter Loader
  void loadFamilyRankings(String timeline) {
    selectedRankingTimeline.value = timeline;
    // Mock mapping datasets representing high-speed memory lookups (Redis cache mimics)
    globalFamilyRankings.assignAll([
      const FamilyModel(
          id: "f_1",
          name: "Lucknow Warriors",
          logo: "https://picsum.photos/60",
          banner: "",
          description: "",
          notice: "",
          level: 12,
          points: 84500,
          currentExp: 0,
          nextLevelExp: 0,
          membersCount: 42,
          maxMembersLimit: 100,
          ownerId: "1",
          ownerName: "Arvind"),
      const FamilyModel(
          id: "f_2",
          name: "Cyber Kings",
          logo: "https://picsum.photos/61",
          banner: "",
          description: "",
          notice: "",
          level: 10,
          points: 72000,
          currentExp: 0,
          nextLevelExp: 0,
          membersCount: 65,
          maxMembersLimit: 100,
          ownerId: "2",
          ownerName: "Rahul"),
      const FamilyModel(
          id: "f_3",
          name: "UP Tigers",
          logo: "https://picsum.photos/62",
          banner: "",
          description: "",
          notice: "",
          level: 8,
          points: 51000,
          currentExp: 0,
          nextLevelExp: 0,
          membersCount: 30,
          maxMembersLimit: 100,
          ownerId: "3",
          ownerName: "Amit"),
    ]);
  }

  // 3. Structural Mutations Administration Functions
  Future<void> createNewFamily(
      {required String name, required String desc}) async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 1000));
    Get.snackbar("Family Registry", "New Family Core Hub generated safely! 👑");
    isLoading.value = false;
    Get.back();
  }

  void updateFamilySettings(String notice, String description) {
    if (currentFamily.value != null) {
      currentFamily.value = currentFamily.value!.copyWith(
        notice: notice,
        description: description,
      );
      Get.snackbar("Vault Sync", "Family operational protocols distributed.");
    }
  }

  void kickMember(String uid) {
    familyMembersList.removeWhere((element) => element.userId == uid);
    Get.snackbar(
        "Enforcement", "User identifiers token removed from family arrays.");
  }
}
