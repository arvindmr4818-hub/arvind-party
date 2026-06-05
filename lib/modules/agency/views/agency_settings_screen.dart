import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencySettingsScreen extends StatefulWidget {
  const AgencySettingsScreen({super.key});

  @override
  State<AgencySettingsScreen> createState() => _AgencySettingsScreenState();
}

class _AgencySettingsScreenState extends State<AgencySettingsScreen> {
  final AgencyController controller = Get.find<AgencyController>();
  final _recruitmentToggle = true.obs;

  @override
  void initState() {
    super.initState();
    if (controller.currentAgency.value != null) {
      _recruitmentToggle.value =
          controller.currentAgency.value!.isOpenForRecruitment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Contract Settings Panel",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Talent Ingestion Pipelines Control",
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),

                // Custom Recruitment Toggle Row Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xff15141F),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                        const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Public Recruitment Status",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                          SizedBox(height: 2),
                          Text(
                              "Allow external anchors to submit contract sheets",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                      Obx(() => Switch(
                            value: _recruitmentToggle.value,
                            activeColor: Colors.cyan,
                            onChanged: (val) {
                              _recruitmentToggle.value = val;
                              controller.patchRecruitmentStatus(val);
                            },
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text("Corporate Security Protocol",
                    style: TextStyle(color: Colors.white24, fontSize: 11)),
                const SizedBox(height: 10),
                TextButton.icon(
                  style: TextButton.styleFrom(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.zero),
                  onPressed: () => Get.snackbar("System Security",
                      "Corporate asset nodes identity mapping verified."),
                  icon: const Icon(Icons.verified_user_outlined,
                      color: Colors.cyan, size: 16),
                  label: const Text("Verify System Ledger Integration Tokens",
                      style: TextStyle(color: Colors.cyan, fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
