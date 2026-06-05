// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/widgets/seat_grid_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../models/seat_model.dart';

class SeatGridWidget extends StatelessWidget {
  const SeatGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return Obx(() {
      if (ctrl.seats.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFFFF8906)),
        );
      }

      final count = ctrl.seats.length;
      // crossAxisCount: 4 for ≤12, 5 for >12
      final crossAxis = count > 12 ? 5 : 4;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: count,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxis,
          crossAxisSpacing: 10,
          mainAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        itemBuilder: (_, i) => _SeatTile(index: i, seat: ctrl.seats[i]),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEAT TILE
// ─────────────────────────────────────────────────────────────────────────────

class _SeatTile extends StatelessWidget {
  final int index;
  final SeatModel seat;
  const _SeatTile({required this.index, required this.seat});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();
    final bool occupied = seat.isOccupied;
    final bool speaking = seat.isSpeaking && !seat.isMuted;

    return GestureDetector(
      onTap: () => _onTap(ctrl),
      onLongPress: occupied ? () => _onLongPress(ctrl) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Avatar / Empty Slot ──────────────────────────────────────────
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Speaking glow ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: speaking
                          ? const Color(0xFFFF8906)
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: speaking
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF8906).withOpacity(0.35),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF2A2838),
                    backgroundImage:
                        occupied ? NetworkImage(seat.avatar!) : null,
                    child: !occupied
                        ? Icon(
                            seat.isLocked
                                ? Icons.lock_outline
                                : Icons.mic_none_outlined,
                            color: seat.isLocked
                                ? Colors.redAccent.withOpacity(0.6)
                                : Colors.white24,
                            size: 18,
                          )
                        : null,
                  ),
                ),

                // Host / CoHost badge (top)
                if (occupied && (seat.isHost || seat.isCoHost))
                  Positioned(
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: seat.isHost
                            ? const Color(0xFFFF8906)
                            : Colors.cyanAccent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        seat.isHost ? 'HOST' : 'CO',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 7,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                // Muted badge (bottom-right)
                if (occupied && seat.isMuted)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_off,
                          color: Colors.white, size: 9),
                    ),
                  ),

                // Locked overlay
                if (seat.isLocked && !occupied)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red.withOpacity(0.07),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          // ── Name / Seat number ───────────────────────────────────────────
          Text(
            occupied ? (seat.userName ?? '') : '${seat.seatNumber}',
            style: TextStyle(
              color: occupied ? Colors.white : Colors.white30,
              fontSize: 10,
              fontWeight: occupied ? FontWeight.w600 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── TAP HANDLER ──────────────────────────────────────────────────────────

  void _onTap(RoomController ctrl) {
    if (!seat.isOccupied) {
      // Khali seat
      if (seat.isLocked && !ctrl.canManageRoom) {
        Get.snackbar('🔒 Locked', 'This seat is locked by host.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF15141F),
            colorText: Colors.white);
        return;
      }
      _showEmptySeatSheet(ctrl);
    } else {
      // Bhari seat - agar meri seat hai toh mute toggle
      if (seat.userId == 'me') {
        // TODO: real userId check
        ctrl.toggleSelfMute();
      }
    }
  }

  void _onLongPress(RoomController ctrl) {
    if (ctrl.canManageMembers) {
      _showAdminSeatSheet(ctrl);
    }
  }

  // ─── EMPTY SEAT BOTTOM SHEET ──────────────────────────────────────────────

  void _showEmptySeatSheet(RoomController ctrl) {
    Get.bottomSheet(
      _BottomSheet(
        title: 'Seat ${seat.seatNumber}',
        children: [
          _SheetTile(
            icon: Icons.mic,
            iconColor: const Color(0xFFFF8906),
            label: 'Take This Seat',
            onTap: () {
              Get.back();
              ctrl.takeSeat(index, 'me', 'You', ''); // TODO: real user data
            },
          ),
          if (ctrl.canManageRoom) ...[
            _SheetTile(
              icon: seat.isLocked ? Icons.lock_open : Icons.lock_outline,
              iconColor: Colors.amber,
              label: seat.isLocked ? 'Unlock Seat' : 'Lock Seat',
              onTap: () {
                Get.back();
                ctrl.toggleLockSeat(index);
              },
            ),
          ],
        ],
      ),
    );
  }

  // ─── ADMIN SEAT BOTTOM SHEET ──────────────────────────────────────────────

  void _showAdminSeatSheet(RoomController ctrl) {
    Get.bottomSheet(
      _BottomSheet(
        title: seat.userName ?? 'User',
        children: [
          _SheetTile(
            icon: seat.isMuted ? Icons.mic : Icons.mic_off,
            iconColor: Colors.amber,
            label: seat.isMuted ? 'Unmute Mic' : 'Mute Mic',
            onTap: () {
              Get.back();
              ctrl.toggleMuteSeatByAdmin(index);
            },
          ),
          _SheetTile(
            icon: Icons.logout,
            iconColor: Colors.redAccent,
            label: 'Kick from Mic',
            onTap: () {
              Get.back();
              ctrl.kickUserFromSeat(index);
            },
          ),
          if (ctrl.canManageRoom)
            _SheetTile(
              icon: seat.isLocked ? Icons.lock_open : Icons.lock_outline,
              iconColor: Colors.white38,
              label: seat.isLocked ? 'Unlock Seat' : 'Lock Seat',
              onTap: () {
                Get.back();
                ctrl.toggleLockSeat(index);
              },
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE BOTTOM SHEET WRAPPER
// ─────────────────────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _BottomSheet({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF15141F),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  const _SheetTile(
      {required this.icon,
      required this.iconColor,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}
