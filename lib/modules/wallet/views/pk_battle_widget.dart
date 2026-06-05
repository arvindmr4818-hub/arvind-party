import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pk_battle_controller.dart';

class PkBattleWidget extends StatelessWidget {
  const PkBattleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PkBattleController());

    return Obx(() {
      final battle = controller.activeBattle.value;
      if (battle == null) return const SizedBox(); // No active battle

      final totalScore = battle.host1Score + battle.host2Score;
      final h1Ratio = totalScore == 0 ? 0.5 : battle.host1Score / totalScore;
      final h2Ratio = totalScore == 0 ? 0.5 : battle.host2Score / totalScore;

      final minutes =
          (battle.remainingSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (battle.remainingSeconds % 60).toString().padLeft(2, '0');

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer and Title
            Text('⚔️ PK BATTLE ⚔️ - $minutes:$seconds',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 16),

            // Hosts and Scores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHostInfo(
                    battle.host1Name, battle.host1Score, Colors.blueAccent),
                const Text('VS',
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold)),
                _buildHostInfo(
                    battle.host2Name, battle.host2Score, Colors.pinkAccent),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Row(
                children: [
                  Expanded(
                      flex: (h1Ratio * 100).toInt(),
                      child: Container(height: 12, color: Colors.blueAccent)),
                  Expanded(
                      flex: (h2Ratio * 100).toInt(),
                      child: Container(height: 12, color: Colors.pinkAccent)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Dummy action buttons (For testing before real gifts)
            if (battle.isActive)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => controller.sendGiftToHost(1, 100),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent),
                      child: const Text('Gift Left')),
                  ElevatedButton(
                      onPressed: () => controller.sendGiftToHost(2, 100),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent),
                      child: const Text('Gift Right')),
                ],
              )
            else
              ElevatedButton(
                  onPressed: controller.startDummyBattle,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Restart PK')),
          ],
        ),
      );
    });
  }

  Widget _buildHostInfo(String name, int score, Color color) {
    return Column(
      children: [
        CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: const Icon(Icons.person, color: Colors.white)),
        const SizedBox(height: 4),
        Text(name,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        Text(score.toString(),
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}
