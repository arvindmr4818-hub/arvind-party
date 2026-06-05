import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';

class AgencyRankingScreen extends StatelessWidget {
  const AgencyRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AgencyController controller = Get.find<AgencyController>();
    final List<String> cycles = ["Weekly", "Monthly", "Lifetime"];

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
          "Global Guild Standings",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Horizontal Quick Filter Switch Tape Rows
                SizedBox(
                  height: 34,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: cycles.length,
                    itemBuilder: (context, idx) {
                      final c = cycles[idx];
                      return Obx(() {
                        bool active = controller.rankingTimeline.value == c;
                        return GestureDetector(
                          onTap: () => controller.fetchGlobalAgencyStandings(c),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.cyan.withOpacity(0.1)
                                  : const Color(0xff15141F),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color:
                                      active ? Colors.cyan : Colors.transparent,
                                  width: 0.8),
                            ),
                            child: Text(c,
                                style: TextStyle(
                                    color:
                                        active ? Colors.white : Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold)),
                          ),
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Corporate Ranking Feed List Frame
                Expanded(
                  child: Obx(() {
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: controller.globalAgencyRankings.length,
                      itemBuilder: (context, index) {
                        final agc = controller.globalAgencyRankings[index];
                        int rank = index + 1;
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xff15141F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text("#$rank",
                                  style: TextStyle(
                                      color: rank <= 3
                                          ? Colors.cyan
                                          : Colors.white24,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              const SizedBox(width: 16),
                              CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(agc.logo)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(agc.name,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    Text("Level ${agc.level} Network",
                                        style: const TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10)),
                                  ],
                                ),
                              ),
                              Text("\$${agc.monthlyRevenue} 💎",
                                  style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
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
}
