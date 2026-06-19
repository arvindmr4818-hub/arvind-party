// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/presentation/views/gift_history_screen.dart
// ARVIND PARTY - GIFT HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';

class GiftHistoryScreen extends GetView<GiftController> {
  const GiftHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GiftController());
    return Scaffold(
      appBar: AppBar(title: const Text('Gift History')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.giftHistory.isEmpty) {
          return const Center(
            child: Text('No gift history yet', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.giftHistory.length,
          itemBuilder: (context, index) {
            final item = controller.giftHistory[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                leading: const Icon(Icons.card_giftcard, color: Color(0xFFFF8906)),
                title: Text('${item.senderName} → ${item.receiverName}', style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.gift.name, style: const TextStyle(color: Colors.grey)),
                trailing: Text('${item.gift.price} coins', style: const TextStyle(color: Color(0xFFD4AF37))),
              ),
            );
          },
        );
      }),
    );
  }
}