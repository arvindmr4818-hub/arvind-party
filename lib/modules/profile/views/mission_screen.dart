import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../controllers/mission_controller.dart';

class MissionScreen extends StatelessWidget {
  final MissionController controller = Get.put(MissionController());

  MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        title: const Text('Daily Missions', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff15141F),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.missions.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }

        return RefreshIndicator(
          color: const Color(0xFFFF8906),
          backgroundColor: const Color(0xff15141F),
          onRefresh: controller.fetchMissions,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.missions.length,
            itemBuilder: (context, index) {
              final mission = controller.missions[index];
              double percent = mission.currentProgress / mission.target;
              if (percent > 1.0) percent = 1.0; // Clamp max

              return Card(
                color: const Color(0xff15141F),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.star_rounded, color: Colors.orange, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(mission.title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(mission.description, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 18),
                              const SizedBox(height: 2),
                              Text('+${mission.rewardCoins}', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${mission.currentProgress} / ${mission.target}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 6),
                            LinearPercentIndicator(lineHeight: 8.0, percent: percent, padding: EdgeInsets.zero, backgroundColor: Colors.white12, progressColor: mission.isCompleted ? Colors.green : const Color(0xFFFF8906), barRadius: const Radius.circular(4)),
                          ])),
                          const SizedBox(width: 16),
                          SizedBox(width: 90, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: mission.isClaimed ? Colors.white12 : (mission.isCompleted ? const Color(0xFFFF8906) : Colors.white12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), onPressed: (mission.isCompleted && !mission.isClaimed) ? () => controller.claimReward(mission.id) : null, child: Text(mission.isClaimed ? 'Claimed' : (mission.isCompleted ? 'Claim' : 'Go'), style: TextStyle(color: (mission.isCompleted && !mission.isClaimed) ? Colors.white : Colors.white54, fontWeight: FontWeight.bold, fontSize: 12))))
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
