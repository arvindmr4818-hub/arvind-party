import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pk_battle_controller.dart';

class PkBattleWidget extends StatelessWidget {
  const PkBattleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PkBattleController());

    return Obx(() {
      final battle = controller.currentBattle.value;
      if (battle == null) return const SizedBox(); 

      final totalScore = battle.hostScore + battle.opponentScore;
      final h1Ratio = totalScore == 0 ? 0.5 : battle.hostScore / totalScore;
      final h2Ratio = totalScore == 0 ? 0.5 : battle.opponentScore / totalScore;

      final isBattleLive = battle.status.toLowerCase() == 'live';

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isBattleLive ? '⚔️ LIVE PK BATTLE ⚔️' : '🏁 BATTLE ENDED',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ✅ FIX: String? values safely casted using null-coalescing string operators
                _buildHostInfo((battle.hostName ?? 'You').toString(), battle.hostScore, Colors.blueAccent),
                const Text('VS',
                    style: TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold)),
                _buildHostInfo((battle.opponentName ?? 'Opponent').toString(), battle.opponentScore, Colors.pinkAccent),
              ],
            ),
            const SizedBox(height: 12),

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
            const SizedBox(height: 16),

            if (isBattleLive)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                      onPressed: () => controller.sendGiftDuringBattle('g_left_100', 100),
                      icon: const Icon(Icons.card_giftcard, size: 16, color: Colors.white),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                      label: const Text('Gift Left (100)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ElevatedButton.icon(
                      onPressed: () => controller.sendGiftDuringBattle('g_right_100', 100),
                      icon: const Icon(Icons.card_giftcard, size: 16, color: Colors.white),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                      label: const Text('Gift Right (100)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                ],
              )
            else
              ElevatedButton.icon(
                  // ✅ FIX: Strict null-safe validation types mappings passed safely
                  onPressed: () => controller.startBattle(
                    opponentId: battle.opponentId ?? '', 
                    opponentName: battle.opponentName ?? 'Opponent', 
                    opponentAvatar: battle.opponentAvatar ?? '', 
                    roomId: battle.roomId ?? ''
                  ),
                  icon: const Icon(Icons.bolt, color: Colors.white),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  label: const Text('Rematch / Start New PK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(score.toString(), style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    );
  }
}