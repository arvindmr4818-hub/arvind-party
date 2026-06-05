import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';
import '../widgets/host_tile.dart';

class AgencyMembersScreen extends StatelessWidget {
  const AgencyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AgencyController controller = Get.find<AgencyController>();

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
              "Contracted Talent Roster (${controller.agencyHostsList.length})",
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
                // Real-time Content Filter Field
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText:
                        "Search contracted anchors by name or Host UID...",
                    hintStyle:
                        const TextStyle(color: Colors.white24, fontSize: 13),
                    prefixIcon: const Icon(Icons.badge_outlined,
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
                  "All Active Talent Nodes",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),

                // Core Hosts Roster Stream
                Expanded(
                  child: Obx(() {
                    if (controller.agencyHostsList.isEmpty) {
                      return const Center(
                        child: Text("No records available in talent grids.",
                            style:
                                TextStyle(color: Colors.white24, fontSize: 13)),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.agencyHostsList.length,
                      itemBuilder: (context, index) {
                        final hostNode = controller.agencyHostsList[index];
                        return HostTile(
                          host: hostNode,
                          onActionTriggered: () {
                            _displayTalentManagementSheet(
                                context, hostNode.username, hostNode.hostId);
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

  void _displayTalentManagementSheet(
      BuildContext context, String name, String uid) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xff15141F),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Manage $name",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            Text("UID: $uid",
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 16),
            ListTile(
              leading:
                  const Icon(Icons.military_tech_outlined, color: Colors.amber),
              title: const Text("Promote Contract Tier Level",
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              onTap: () {
                Get.back();
                Get.snackbar(
                    "Contract Core", "Tier modification pipelines updated.");
              },
            ),
            ListTile(
              leading: const Icon(Icons.no_accounts_outlined,
                  color: Colors.redAccent),
              title: const Text("Terminate Contract & Sever Linkages",
                  style: TextStyle(color: Colors.redAccent, fontSize: 13)),
              onTap: () {
                Get.back();
                Get.snackbar("Contract Severed",
                    "Anchor removed from database mappings.");
              },
            ),
          ],
        ),
      ),
    );
  }
}
