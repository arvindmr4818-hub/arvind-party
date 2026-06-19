// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/presentation/views/gift_ranking_screen.dart
// ARVIND PARTY - GIFT RANKING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';

class GiftRankingScreen extends GetView<GiftController> {
  const GiftRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Ranking')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.giftRanking.isEmpty) {
          return const Center(
            child: Text('No rankings yet', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.giftRanking.length,
          itemBuilder: (context, index) {
            final entry = controller.giftRanking[index];
            return ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFFF8906),
                child: Text('\${index + 1}', style: TextStyle(color: Colors.white)),
              ),
              title: Text(entry['username'] ?? '', style: const TextStyle(color: Colors.white)),
              trailing: Text("${entry['totalCoins']} coins", style: const TextStyle(color: Color(0xFFD4AF37))),
            );
          },
        );
      }),
    );
  }
}