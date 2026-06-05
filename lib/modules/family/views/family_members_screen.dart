import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';
import '../widgets/family_member_tile.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FamilyController controller = Get.find<FamilyController>();

    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
              "Clan Roster (${controller.familyMembersList.length})",
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            )),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Search Bar Node
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search clan members by name or ID...",
                    hintStyle:
                        const TextStyle(color: Colors.white24, fontSize: 13),
                    prefixIcon: const Icon(Icons.search,
                        color: Colors.white38, size: 18),
                    filled: true,
                    fillColor: const Color(0xff15141F),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  "All Active Alignments",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // Core Members Array Feed Stream
                Expanded(
                  child: Obx(() {
                    if (controller.familyMembersList.isEmpty) {
                      return const Center(
                        child: Text("No member footprints matched.",
                            style:
                                TextStyle(color: Colors.white24, fontSize: 13)),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.familyMembersList.length,
                      itemBuilder: (context, index) {
                        final member = controller.familyMembersList[index];
                        return FamilyMemberTile(
                          member: member,
                          onKickPressed: () {
                            _confirmKickAction(context, controller,
                                member.userId, member.name);
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmKickAction(BuildContext context, FamilyController controller,
      String uid, String name) {
    if (uid == "me_123") {
      Get.snackbar("Constraint Error",
          "Family owners cannot self-terminate privileges from rosters.");
      return;
    }

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xff15141F),
        title: const Text("Sever Alliance?",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        content: Text(
            "Are you absolutely sure you want to strip $name from family arrays?",
            style: const TextStyle(color: Colors.white70, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text("Cancel",
                  style: TextStyle(color: Colors.white30))),
          TextButton(
            onPressed: () {
              Get.back();
              controller.kickMember(uid);
            },
            child: const Text("Kick Out",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
