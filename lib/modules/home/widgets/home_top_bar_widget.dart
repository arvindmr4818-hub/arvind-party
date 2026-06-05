// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/widgets/home_top_bar_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../../routes/app_routes.dart';

class HomeTopBarWidget extends StatelessWidget {
  const HomeTopBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Row(
        children: [
          // ── App Logo + Greeting ────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF8906), Color(0xFFFFB347)],
                        ),
                      ),
                      child:
                          const Icon(Icons.mic, color: Colors.black, size: 14),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ARVIND PARTY',
                      style: TextStyle(
                        color: Color(0xFFFF8906),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      'Hey, ${ctrl.userName.value} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ),

          // ── Coins Display ─────────────────────────────────────────────
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.wallet),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF15141F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFF8906).withOpacity(0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 5),
                  Obx(() => Text(
                        _formatCoins(ctrl.userCoins.value),
                        style: const TextStyle(
                          color: Color(0xFFFF8906),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      )),
                  const SizedBox(width: 4),
                  const Icon(Icons.add_circle,
                      color: Color(0xFFFF8906), size: 14),
                ],
              ),
            ),
          ),

          // ── Notification Bell ─────────────────────────────────────────
          Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: Notifications screen
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15141F),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      color: Colors.white70, size: 20),
                ),
              ),
              // Notification badge
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                      color: Colors.redAccent, shape: BoxShape.circle),
                  child: const Center(
                    child: Text('3',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCoins(int coins) {
    if (coins >= 1000000) return '${(coins / 1000000).toStringAsFixed(1)}M';
    if (coins >= 1000) return '${(coins / 1000).toStringAsFixed(1)}K';
    return '$coins';
  }
}
