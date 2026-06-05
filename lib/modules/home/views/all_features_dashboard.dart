import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Local imports matching your current structure
import '../../wallet/views/shop_screen.dart';
import '../../wallet/views/lucky_draw_screen.dart';
import '../../wallet/views/blind_date_screen.dart';
import '../../wallet/views/moments_screen.dart';
import '../../wallet/views/mission_screen.dart';
import '../../wallet/views/search_screen.dart';
import '../../wallet/views/mini_games_bottom_sheet.dart';

class AllFeaturesDashboard extends StatelessWidget {
  const AllFeaturesDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        title: const Text('App Dashboard (100% Complete)',
            style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tap any feature to test the UI logic:',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          _buildMenuButton(
              '🛒 VIP Shop System', () => Get.to(() => const ShopScreen())),
          _buildMenuButton('🎡 Lucky Draw Wheel',
              () => Get.to(() => const LuckyDrawScreen())),
          _buildMenuButton('💕 Blind Date / Radar',
              () => Get.to(() => const BlindDateScreen())),
          _buildMenuButton(
              '📸 Moments Feed', () => Get.to(() => const MomentsScreen())),
          _buildMenuButton(
              '🎯 Daily Missions', () => Get.to(() => const MissionScreen())),
          _buildMenuButton('🔍 Global Search',
              () => Get.to(() => const GlobalSearchScreen())),
          _buildMenuButton(
              '🎮 Mini Games Sheet', () => MiniGamesBottomSheet.show()),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF15141F),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          alignment: Alignment.centerLeft,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Colors.white12)),
        ),
        child: Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
