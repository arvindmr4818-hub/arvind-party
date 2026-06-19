// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/moments/presentation/views/moments_screen.dart
// ARVIND PARTY - MOMENTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/moments_controller.dart';

class MomentsScreen extends GetView<MomentsController> {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Moments')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.posts.isEmpty) {
          return const Center(
            child: Text('No moments yet', style: TextStyle(color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFF8906),
                      child: Text(post['userName']?.toString().substring(0, 1) ?? '?'),
                    ),
                    title: Text(post['userName'] ?? '', style: const TextStyle(color: Colors.white)),
                    subtitle: Text(post['timestamp'] ?? '', style: const TextStyle(color: Colors.grey)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(post['content'] ?? '', style: const TextStyle(color: Colors.white)),
                  ),
                  OverflowBar(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Colors.red),
                        onPressed: () => controller.likePost(post['id'] ?? ''),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}