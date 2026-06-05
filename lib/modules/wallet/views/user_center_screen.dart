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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
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
          if (controller.isLoading.value) {
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
                    color: const Color(0xFFFF8906).withOpacity(0.5),
                    blurRadius: 25,
                    offset: const Offset(0, 10)),
              ],
            ),
            alignment: Alignment.center,
            child: Text('Lv. ${info.currentLevel}',
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('EXP: ${info.currentExp}',
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold)),
              Text('${info.nextLevelExp}',
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: info.progressPercentage,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFF8906)),
              minHeight: 16,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Need ${info.nextLevelExp - info.currentExp} more EXP to reach Level ${info.currentLevel + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesTab(UserCenterController controller) {
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
        return Opacity(
          opacity: badge.isUnlocked ? 1.0 : 0.4,
          child: Container(
            decoration: BoxDecoration(
                color: const Color(0xFF15141F),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(badge.iconPath, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(badge.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(badge.description,
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFramesTab(UserCenterController controller) {
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
                        color: frame.isUnlocked
                            ? const Color(0xFF2CB67D)
                            : Colors.grey,
                        width: 3)),
                child:
                    const Icon(Icons.person, color: Colors.white38, size: 36),
              ),
              const SizedBox(height: 16),
              Text(frame.name,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (!frame.isUnlocked)
                const Icon(Icons.lock, color: Colors.white38)
              else if (frame.isEquipped)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFF8906).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text('Equipped',
                        style: TextStyle(
                            color: Color(0xFFFF8906),
                            fontSize: 12,
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
                            fontSize: 12,
                            fontWeight: FontWeight.bold)))
            ],
          ),
        );
      },
    );
  }
}
