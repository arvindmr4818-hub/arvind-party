import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/mission_controller.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MissionController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('Daily Missions',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.dailyTasks.length,
            itemBuilder: (context, index) {
              final task = controller.dailyTasks[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF15141F),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white10,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.monetization_on,
                          color: Colors.yellowAccent, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(task.title,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(task.description,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: task.progress / task.target,
                            backgroundColor: Colors.white12,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF8906)),
                          ),
                          const SizedBox(height: 4),
                          Text('${task.progress} / ${task.target}',
                              style: const TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: task.isCompleted && !task.isClaimed
                          ? () => controller.claimReward(task.id)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: task.isClaimed
                            ? Colors.white10
                            : (task.isCompleted
                                ? const Color(0xFF2CB67D)
                                : Colors.white10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        task.isClaimed
                            ? 'Claimed'
                            : (task.isCompleted ? 'Claim' : 'Go'),
                        style: TextStyle(
                            color: task.isClaimed || !task.isCompleted
                                ? Colors.white54
                                : Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
    );
  }
}
