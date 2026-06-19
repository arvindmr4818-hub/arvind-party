import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/block_controller.dart';
import '../widgets/blocked_tile.dart';
import '../widgets/muted_tile.dart';

class BlacklistScreen extends GetView<BlockController> {
  const BlacklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(BlockController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blacklist & Mutes', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.block), text: 'Blocked'),
                Tab(icon: Icon(Icons.volume_off), text: 'Muted'),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
                return TabBarView(
                  children: [
                    controller.blockedUsers.isEmpty
                        ? const Center(child: Text('No blocked users', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: controller.blockedUsers.length,
                            itemBuilder: (context, index) => BlockedTile(user: controller.blockedUsers[index]),
                          ),
                    controller.mutedUsers.isEmpty
                        ? const Center(child: Text('No muted users', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: controller.mutedUsers.length,
                            itemBuilder: (context, index) => MutedTile(user: controller.mutedUsers[index]),
                          ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}