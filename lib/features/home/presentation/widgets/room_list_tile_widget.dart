// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/widgets/room_list_tile_widget.dart
// Used in: RoomsTab (full-width list)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../room/models/room_models.dart';
import '../../../room/controllers/room_controller.dart';
import '../../../../routes/app_routes.dart';

class RoomListTileWidget extends StatelessWidget {
  final RoomModel room;
  const RoomListTileWidget({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _joinRoom(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF15141F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            // ── Banner Thumbnail ────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Image.network(
                  room.banner ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFF2A2838),
                    child:
                        const Icon(Icons.mic, color: Colors.white24, size: 28),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Info ────────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + type icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.title ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (room.roomType != 'public')
                        Icon(
                          room.roomType == 'password'
                              ? Icons.vpn_key
                              : Icons.lock_outline,
                          color: Colors.amber,
                          size: 14,
                        ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Topic
                  Text(
                    room.topic ?? '',
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Stats row
                  Row(
                    children: [
                      // Online
                      _StatChip(
                        icon: Icons.people,
                        color: Colors.cyanAccent,
                        label: _formatOnline(room.onlineUsers),
                      ),
                      const SizedBox(width: 8),
                      // Seats
                      _StatChip(
                        icon: Icons.mic,
                        color: const Color(0xFFFF8906),
                        label: '${room.seatCount} mic',
                      ),
                      const Spacer(),
                      // Join Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF8906), Color(0xFFFFB347)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Join',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
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
      _navigate();
    }
  }

  void _navigate() {
    final roomCtrl = Get.find<RoomController>();
    roomCtrl.joinRoom(room.id);
    Get.toNamed(AppRoutes.voiceRoom);
  }

  void _showPasswordDialog() {
    final tc = TextEditingController();
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF15141F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Enter Password',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: TextField(
        controller: tc,
        obscureText: true,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Room password',
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
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () {
            Get.back();
            if (tc.text.trim() == (room.password ?? '')) {
              _navigate();
            } else {
              Get.snackbar('Wrong Password', 'Please try again.',
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
    ));
  }

  String _formatOnline(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  const _StatChip(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
