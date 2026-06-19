// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/ranking/presentation/views/game_leaderboard_screen.dart
// ARVIND PARTY - GAME LEADERBOARD SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ranking_controller.dart';

class GameLeaderboardScreen extends GetView<RankingController> {
  const GameLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.rankings.isEmpty) {
          return const Center(
            child: Text('No rankings available', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.rankings.length,
          itemBuilder: (context, index) {
            final entry = controller.rankings[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: index < 3 ? const Color(0xFFD4AF37) : const Color(0xFF2D2D44),
                child: const Text('\${index + 1}', style: TextStyle(color: Colors.white)),
              ),
              title: Text(entry['userName'] ?? '', style: const TextStyle(color: Colors.white)),
              trailing: Text('${entry['score']} pts', style: const TextStyle(color: Color(0xFFD4AF37))),
            );
          },
        );
      }),
    );
  }
}