import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';
import 'family_members_screen.dart';
import 'family_chat_screen.dart';
import 'family_events_screen.dart';
import 'family_settings_screen.dart';
import 'family_ranking_screen.dart';

class FamilyHomeScreen extends StatelessWidget {
  const FamilyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecting and retrieving target scope data controller
    final FamilyController controller = Get.put(FamilyController());

    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      body: Obx(() {
        final family = controller.currentFamily.value;
        if (controller.isLoading.value && family == null) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xffFF8906)));
        }
        if (family == null) {
          return const Center(
              child: Text("No family node linked to current user registry.",
                  style: TextStyle(color: Colors.white24)));
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Dynamic Banner Display Core Appbar
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              backgroundColor: const Color(0xff15141F),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios,
                    color: Colors.white, size: 18),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 14),
                title: Text(
                  family.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(family.banner, fit: BoxFit.cover),
                    Container(
                        color: Colors
                            .black54), // Dark shading layer for text readability overlays
                  ],
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.emoji_events_outlined,
                      color: Colors.amber),
                  onPressed: () => Get.to(() => const FamilyRankingScreen()),
                )
              ],
            ),

            // 2. Central Core Statistics Parameters Grid Viewport
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dynamic Profile Snapshot Row Layout
                    _buildIdentitySnapshotCard(family),
                    const SizedBox(height: 16),

                    // Level Progression Bar Indicator
                    _buildLevelProgressBar(family),
                    const SizedBox(height: 20),

                    const Text(
                      "Family Central Hub Command Deck",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),

                    // Navigation Actions Matrix Grid Menu Options
                    _buildNavigationGridMenu(),
                    const SizedBox(height: 16),

                    // Notice Board Announcement Panel Tape Card
                    _buildNoticeBoard(family),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildIdentitySnapshotCard(dynamic family) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(family.logo),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xffFF8906),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text("LVL ${family.level}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text("🛡️ Points: ${family.points}",
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  family.description,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgressBar(dynamic family) {
    double progressRatio = family.currentExp / family.nextLevelExp;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Progression Track",
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
              Text("${family.currentExp}/${family.nextLevelExp} EXP",
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressRatio,
              backgroundColor: const Color(0xff0F0E17),
              color: const Color(0xffFF8906),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationGridMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {
        "title": "Members",
        "subtitle": "View crew roster",
        "icon": Icons.groups_outlined,
        "color": Colors.cyan,
        "screen": () => const FamilyMembersScreen()
      },
      {
        "title": "Family Chat",
        "subtitle": "Internal channels",
        "icon": Icons.forum_outlined,
        "color": Colors.greenAccent,
        "screen": () => const FamilyChatScreen()
      },
      {
        "title": "Scheduled Events",
        "subtitle": "PK music matches",
        "icon": Icons.event_note_outlined,
        "color": Colors.amber,
        "screen": () => const FamilyEventsScreen()
      },
      {
        "title": "Settings Deck",
        "subtitle": "Owner parameters",
        "icon": Icons.tune_outlined,
        "color": Colors.purpleAccent,
        "screen": () => const FamilySettingsScreen()
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.45,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final action = menuItems[index];
        return InkWell(
          onTap: () => Get.to(action['screen']),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff15141F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.01)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(action['icon'], color: action['color'], size: 24),
                const SizedBox(height: 8),
                Text(action['title'],
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(action['subtitle'],
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoticeBoard(dynamic family) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff1A1924),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_outlined, color: Colors.cyan, size: 18),
              SizedBox(width: 6),
              Text("Pinned Family Notice Board",
                  style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            family.notice,
            style:
                const TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}
