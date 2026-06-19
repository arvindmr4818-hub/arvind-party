import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart'; // Safely targets your relative sub-folder layout
import '../widgets/room_header_widget.dart';
import '../widgets/room_banner_widget.dart';
import '../widgets/seat_grid_widget.dart';
import '../widgets/room_chat_widget.dart';
import '../widgets/room_bottom_bar_widget.dart';

class RoomScreen extends StatelessWidget {
  const RoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RoomController ctrl = Get.find<RoomController>();

    // FIXED: Upgraded from legacy WillPopScope to state-safe PopScope API configuration
    return PopScope(
      canPop: false, 
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitDialog(ctrl);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E17),
        body: SafeArea(
          child: Column(
            children: [
              // ── 1. HEADER CONTAINER (Title, Online limits metrics parameters) ──
              const RoomHeaderWidget(),

              // ── 2. SCROLLABLE LIVE INTERACTION HUB BODY ───────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // FIXED: Removed the broken duplicate non-existent 'RoomHeader()' widget line reference
                      const RoomBannerWidget(),

                      const SizedBox(height: 8),

                      // Seat Grid Configuration Interface Deck (Handles 8/10/15/20/25 sizes scales)
                      const SeatGridWidget(),

                      const SizedBox(height: 8),

                      // FIXED: Migrated legacy withOpacity layout format syntax to contemporary performance rules
                      Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),

                      const SizedBox(height: 4),

                      // Real-time Text Messaging Flow Viewer Widgets Panel
                      const RoomChatWidget(),

                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),

              // ── 3. BOTTOM AUDIO SHIELD CONTROLS BAR (Mic, Chat toggles, Gifts catalog) ──
              const RoomBottomBarWidget(),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // DISSOCIATION DIALOG WORKFLOW WARNING ENVIRONMENT
  // ══════════════════════════════════════════════════════════════
  void _showExitDialog(RoomController ctrl) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Room?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to exit this party session?',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Stay', style: TextStyle(color: Colors.white38)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Dismiss context warning overlay anchor window
              ctrl.leaveRoom(); // Execution detachment loop trigger pipeline
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}