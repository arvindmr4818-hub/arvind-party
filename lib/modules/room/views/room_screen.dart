// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/views/room_screen.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../widgets/room_header_widget.dart';
import '../widgets/room_banner_widget.dart';
import '../widgets/seat_grid_widget.dart';
import '../widgets/room_chat_widget.dart';
import '../widgets/room_bottom_bar_widget.dart';
import '../widgets/raise_hand_sheet.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RoomController ctrl = Get.find<RoomController>();

    return WillPopScope(
      onWillPop: () async {
        _showExitDialog(ctrl);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E17),
        body: SafeArea(
          child: Column(
            children: [
              // ── 1. Header (Title, Online count, Members button) ──────────
              const RoomHeaderWidget(),

              // ── 2. Scrollable Body ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // Banner + Announcement + Pinned
                      const RoomHeader(),
                      const RoomBannerWidget(),

                      const SizedBox(height: 8),

                      // Seat Grid (8/10/15/20/25)
                      const SeatGridWidget(),

                      const SizedBox(height: 8),

                      Divider(color: Colors.white.withOpacity(0.05), height: 1),

                      const SizedBox(height: 4),

                      // Chat Messages
                      const RoomChatWidget(),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // ── 3. Bottom Bar (mic, chat input, gift, more) ───────────────
              const RoomBottomBarWidget(),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitDialog(RoomController ctrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Leave Room?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit this party session?',
            style: TextStyle(color: Colors.white60, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Stay', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: ctrl.leaveRoom,
            child: const Text('Leave',
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
