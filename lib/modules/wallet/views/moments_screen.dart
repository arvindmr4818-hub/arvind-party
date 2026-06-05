import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'moments_controller.dart';

class MomentsScreen extends StatelessWidget {
  const MomentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MomentsController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('Moments',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_box, color: Color(0xFFFF8906)),
              onPressed: () {
                // TODO: Navigate to Create Post Screen
              }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF8906)));
        }
        return ListView.builder(
          itemCount: controller.posts.length,
          itemBuilder: (context, index) {
            final post = controller.posts[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF15141F),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      CircleAvatar(
                          backgroundImage: NetworkImage(post.userAvatar),
                          radius: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(post.userName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const Text('2 hours ago',
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontSize:
                                        12)), // Format DateTime properly later
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.more_vert,
                              color: Colors.white54),
                          onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Content
                  Text(post.content,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                  if (post.imageUrl != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(post.imageUrl!,
                            width: double.infinity, fit: BoxFit.cover)),
                  ],
                  const SizedBox(height: 16),
                  // Actions
                  Row(
                    children: [
                      GestureDetector(
                          onTap: () => controller.toggleLike(post.id),
                          child: Row(children: [
                            Icon(
                                post.isLikedByMe
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: post.isLikedByMe
                                    ? Colors.redAccent
                                    : Colors.white54,
                                size: 20),
                            const SizedBox(width: 6),
                            Text('${post.likesCount}',
                                style: const TextStyle(color: Colors.white54))
                          ])),
                      const SizedBox(width: 24),
                      Row(children: [
                        const Icon(Icons.comment_outlined,
                            color: Colors.white54, size: 20),
                        const SizedBox(width: 6),
                        Text('${post.commentsCount}',
                            style: const TextStyle(color: Colors.white54))
                      ]),
                    ],
                  )
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
