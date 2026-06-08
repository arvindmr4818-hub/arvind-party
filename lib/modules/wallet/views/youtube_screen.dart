import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/youtube_controller.dart';

class YoutubeScreen extends StatelessWidget {
  const YoutubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(YoutubeController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('YouTube Room',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Column(
        children: [
          // Player Screen Display View Frame
          Obx(() {
            final video = controller.currentVideo.value;
            if (video == null) {
              return Container(
                height: 220,
                width: double.infinity,
                color: Colors.black,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ondemand_video, color: Colors.white38, size: 48),
                    SizedBox(height: 12),
                    Text('Select a video to start Watch Party',
                        style: TextStyle(color: Colors.white54)),
                  ],
                ),
              );
            }
            return Container(
              height: 220,
              width: double.infinity,
              color: Colors.black,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ✅ FIX 2: Corrected item.thumbnail to item.thumbnailUrl to match model definition
                  Image.network(video.thumbnailUrl.isNotEmpty ? video.thumbnailUrl : 'https://via.placeholder.com/640x360',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.white24, size: 40),
                      opacity: const AlwaysStoppedAnimation(0.5)),
                  const Icon(Icons.play_circle_fill,
                      color: Colors.redAccent, size: 64),
                  Positioned(
                      top: 16,
                      left: 16,
                      child: Text('Playing: ${video.title}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold))),
                ],
              ),
            );
          }),

          const Divider(color: Colors.white12, height: 1),

          // Real Catalog Video List Streams
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.videos.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              }

              if (controller.videos.isEmpty) {
                return const Center(child: Text('No watch party videos found', style: TextStyle(color: Colors.white38)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.videos.length,
                itemBuilder: (context, index) {
                  final v = controller.videos[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.only(bottom: 16),
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        // ✅ FIX 3: Corrected v.thumbnail to v.thumbnailUrl here as well
                        child: Image.network(v.thumbnailUrl.isNotEmpty ? v.thumbnailUrl : 'https://via.placeholder.com/100x60',
                            width: 100, height: 60, fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(width: 100, height: 60, color: Colors.white10, child: const Icon(Icons.broken_image, color: Colors.white24, size: 20)),
                        )),
                    title: Text(v.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(v.channelTitle.isNotEmpty ? v.channelTitle : 'YouTube Stream',
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: IconButton(
                        icon: const Icon(Icons.play_arrow,
                            color: Color(0xFFFF8906)),
                        onPressed: () => controller.playVideo(v)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}