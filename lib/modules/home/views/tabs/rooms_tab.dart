// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/views/tabs/rooms_tab.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/room_list_tile_widget.dart';
import '../../../../routes/app_routes.dart';

class RoomsTab extends StatelessWidget {
  const RoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ─────────────────────────────────────────────────────
            _RoomsHeader(ctrl: ctrl),

            // ── Filter Chips ───────────────────────────────────────────────
            _FilterRow(ctrl: ctrl),

            const SizedBox(height: 4),

            // ── Room List ──────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.isRoomsLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFFFF8906), strokeWidth: 2),
                  );
                }

                if (ctrl.liveRooms.isEmpty) {
                  return _EmptyRooms(
                      onCreateTap: () => Get.toNamed(AppRoutes.createRoom));
                }

                return RefreshIndicator(
                  color: const Color(0xFFFF8906),
                  backgroundColor: const Color(0xFF15141F),
                  onRefresh: () async =>
                      await Future.delayed(const Duration(milliseconds: 800)),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: ctrl.liveRooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) =>
                        RoomListTileWidget(room: ctrl.liveRooms[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),

      // ── Create Room FAB ────────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.createRoom),
        backgroundColor: const Color(0xFFFF8906),
        icon: const Icon(Icons.mic, color: Colors.black, size: 20),
        label: const Text(
          'Create Room',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        elevation: 4,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _RoomsHeader extends StatelessWidget {
  final HomeController ctrl;
  const _RoomsHeader({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          const Text(
            'Live Rooms',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 10),
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: Colors.redAccent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Obx(() => Text(
                      '${ctrl.liveRooms.length} LIVE',
                      style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const Spacer(),
          // Grid/List toggle (future)
          Icon(Icons.tune, color: Colors.white38, size: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER ROW
// ─────────────────────────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  final HomeController ctrl;
  const _FilterRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: ctrl.roomFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = ctrl.roomFilters[i];
              final selected = ctrl.selectedRoomFilter.value == f;
              return GestureDetector(
                onTap: () => ctrl.selectRoomFilter(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFF8906).withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF8906)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      color:
                          selected ? const Color(0xFFFF8906) : Colors.white38,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          )),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyRooms extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyRooms({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mic_none, color: Colors.white12, size: 64),
          const SizedBox(height: 16),
          const Text('No live rooms right now',
              style: TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Be the first to start a party!',
              style: TextStyle(color: Colors.white24, fontSize: 13)),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: onCreateTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF8906),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic, color: Colors.black, size: 18),
                  SizedBox(width: 8),
                  Text('Create Room',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
