// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/lucky_draw/presentation/views/lucky_draw_screen.dart
// ARVIND PARTY - LUCKY DRAW SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/lucky_draw_controller.dart';

class LuckyDrawScreen extends GetView<LuckyDrawController> {
  const LuckyDrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lucky Draw')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(() => Text(
              controller.prize.value.isNotEmpty ? 'Prize: \${controller.prize.value}' : 'Spin to win!',
              style: const TextStyle(fontSize: 24, color: Colors.white),
            )),
            const SizedBox(height: 32),
            Obx(() => ElevatedButton(
              onPressed: controller.isSpinning.value ? null : () => controller.spin(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8906),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: Text(
                controller.isSpinning.value ? 'Spinning...' : 'SPIN',
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            )),
          ],
        ),
      ),
    );
  }
}