// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/home/views/tabs/discover_tab.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../room/models/room_models.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/room_card_widget.dart';
import '../../widgets/home_top_bar_widget.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ────────────────────────────────────────────────────
            const HomeTopBarWidget(),

            // ── Search Bar ─────────────────────────────────────────────────
            _SearchBar(ctrl: ctrl),

            // ── Category Chips ─────────────────────────────────────────────
            _CategoryRow(ctrl: ctrl),

            const SizedBox(height: 4),

            // ── Room Grid ──────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (ctrl.discoverRooms.isEmpty) {
                  return const _EmptyState(
                    icon: Icons.search_off,
                    title: 'No rooms found',
                    subtitle: 'Try a different search or category',
                  );
                }

                return RefreshIndicator(
                  color: const Color(0xFFFF8906),
                  backgroundColor: const Color(0xFF15141F),
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 800));
                    ctrl.selectCategory(ctrl.selectedCategory.value);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: ctrl.discoverRooms.length,
                    itemBuilder: (_, i) =>
                        RoomCardWidget(room: RoomModel.fromJson(ctrl.discoverRooms[i])),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final HomeController ctrl;
  const _SearchBar({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF15141F),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search, color: Colors.white38, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: ctrl.searchCtrl,
                onChanged: ctrl.onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search rooms, topics...',
                  hintStyle: TextStyle(color: Colors.white30, fontSize: 13),
                  isDense: true,
                ),
              ),
            ),
            Obx(() => ctrl.searchQuery.value.isNotEmpty
                ? GestureDetector(
                    onTap: ctrl.clearSearch,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12),
                      child:
                          Icon(Icons.cancel, color: Colors.white24, size: 18),
                    ),
                  )
                : const SizedBox(width: 12)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CATEGORY CHIPS
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  final HomeController ctrl;
  const _CategoryRow({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: ctrl.categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final cat = ctrl.categories[i];
              final selected = ctrl.selectedCategory.value == cat;
              return GestureDetector(
                onTap: () => ctrl.selectCategory(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFF8906)
                        : const Color(0xFF15141F),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF8906)
                          : Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: selected ? Colors.black : Colors.white60,
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _EmptyState(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white12, size: 64),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: const TextStyle(color: Colors.white24, fontSize: 13)),
        ],
      ),
    );
  }
}
