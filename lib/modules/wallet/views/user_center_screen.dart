import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/user_center_controller.dart';

class UserCenterScreen extends StatelessWidget {
  const UserCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserCenterController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0E17),
        appBar: AppBar(
          backgroundColor: const Color(0xFF15141F),
          elevation: 0,
          title: const Text('User Center',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFFFF8906),
            labelColor: Color(0xFFFF8906),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: 'Level'),
              Tab(text: 'Badges'),
              Tab(text: 'Frames'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.frames.isEmpty) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF8906)));
          }
          return TabBarView(
            children: [
              _buildLevelTab(controller),
              _buildBadgesTab(controller),
              _buildFramesTab(controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLevelTab(UserCenterController controller) {
    final info = controller.levelInfo.value;
    if (info == null) return const SizedBox();

    // ✅ Calculation: Safe mathematical validation division check to get progress ratio
    double calculatedProgress = info.nextLevelXp > 0 ? (info.currentXp / info.nextLevelXp) : 0.0;
    if (calculatedProgress > 1.0) calculatedProgress = 1.0;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFFFF8906), Color(0xFFF25F4C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFFFF8906).withValues(alpha: 0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10)),
              ],
            ),
            alignment: Alignment.center,
            // ✅ FIX 1: Pointed directly to info.level according to controller schema definition
            child: Text('Lv. ${info.level}',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Text(info.title, style: const TextStyle(color: Color(0xFFFF8906), fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 38),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // ✅ FIX 2: Pointed directly to info.currentXp
              Text('EXP: ${info.currentXp}',
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold)),
              // ✅ FIX 3: Pointed directly to info.nextLevelXp
              Text('Next: ${info.nextLevelXp}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              // ✅ FIX 4: Binded safely using calculated runtime division matrix property
              value: calculatedProgress,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFF8906)),
              minHeight: 16,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Need ${info.nextLevelXp - info.currentXp} more XP to reach Level ${info.level + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(UserCenterController controller) {
    if (controller.badges.isEmpty) {
      return const Center(child: Text('No badges unlocked yet', style: TextStyle(color: Colors.white54)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85),
      itemCount: controller.badges.length,
      itemBuilder: (context, index) {
        final badge = controller.badges[index];
        final isUnlocked = badge.unlockedAt != null;

        return Opacity(
          opacity: isUnlocked ? 1.0 : 0.4,
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF15141F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Displaying dynamic network or standard image fallback safely
                badge.iconUrl.isNotEmpty
                    ? Image.network(badge.iconUrl, width: 48, height: 48, errorBuilder: (c,e,s) => const Icon(Icons.stars, size: 48, color: Colors.amber))
                    : const Icon(Icons.stars, size: 48, color: Colors.amber),
                const SizedBox(height: 12),
                Text(badge.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(badge.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFramesTab(UserCenterController controller) {
    if (controller.frames.isEmpty) {
      return const Center(child: Text('No decoration frames catalog parsed', style: TextStyle(color: Colors.white54)));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75),
      itemCount: controller.frames.length,
      itemBuilder: (context, index) {
        final frame = controller.frames[index];
        return Container(
          decoration: BoxDecoration(
              color: const Color(0xFF15141F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: frame.isEquipped
                      ? const Color(0xFFFF8906)
                      : Colors.white12,
                  width: frame.isEquipped ? 2 : 1)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: frame.isOwned ? const Color(0xFF2CB67D) : Colors.grey,
                        width: 2)),
                child: frame.imageUrl.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(35), child: Image.network(frame.imageUrl, fit: BoxFit.cover))
                    : const Icon(Icons.person, color: Colors.white38, size: 36),
              ),
              const SizedBox(height: 16),
              Text(frame.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 16),
              if (!frame.isOwned)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock, color: Colors.white38, size: 14),
                    const SizedBox(width: 4),
                    Text('${frame.priceCoins} C', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                )
              else if (frame.isEquipped)
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF8906).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Equipped',
                        style: TextStyle(
                            color: Color(0xFFFF8906),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)))
              else
                ElevatedButton(
                    onPressed: () => controller.equipFrame(frame.id),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2CB67D),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        minimumSize: const Size(90, 36)),
                    child: const Text('Equip',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)))
            ],
          ),
        );
      },
    );
  }
}