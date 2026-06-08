// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/widgets/room_card_widget.dart
// Used in: DiscoverTab (2-column grid)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../room/models/room_models.dart';
import '../../room/controllers/room_controller.dart';
import '../../../../routes/app_routes.dart';

class RoomCardWidget extends StatelessWidget {
  final RoomModel room;
  const RoomCardWidget({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _joinRoom(),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF15141F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ───────────────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  // Banner image
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        room.banner,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2A2838),
                          child: const Icon(Icons.music_note,
                              color: Colors.white24, size: 32),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),

                  // Online badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatOnline(room.onlineUsers),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Room type badge
                  if (room.roomType != 'public')
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          room.roomType == 'password'
                              ? Icons.vpn_key
                              : Icons.lock_outline,
                          color: Colors.amber,
                          size: 11,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ─────────────────────────────────────────────────────
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      room.topic,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.mic,
                            color: Color(0xFFFF8906), size: 11),
                        const SizedBox(width: 3),
                        Text(
                          '${room.seatCount} seats',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
                        ),
                        const Spacer(),
                        // Join arrow
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF8906).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward,
                              color: Color(0xFFFF8906), size: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinRoom() {
    if (room.roomType == 'password') {
      _showPasswordDialog();
    } else {
      _navigateToRoom();
    }
  }

  void _navigateToRoom() {
    final roomCtrl = Get.find<RoomController>();
    roomCtrl.joinRoom(room);
    Get.toNamed(AppRoutes.voiceRoom);
  }

  void _showPasswordDialog() {
    final tc = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Password Required',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: tc,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter room password',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFF0F0E17),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            prefixIcon:
                const Icon(Icons.vpn_key, color: Color(0xFFFF8906), size: 18),
          ),
        ),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white38))),
          TextButton(
            onPressed: () {
              Get.back();
              if (tc.text.trim() == room.password) {
                _navigateToRoom();
              } else {
                Get.snackbar('Wrong Password', 'Incorrect room password.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF15141F),
                    colorText: Colors.redAccent);
              }
            },
            child: const Text('Join',
                style: TextStyle(
                    color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatOnline(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}
