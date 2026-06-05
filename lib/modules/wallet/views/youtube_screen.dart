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
          // Player Area
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
              // TODO: Replace this container with actual YoutubePlayer widget
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(video.thumbnail,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
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

          // Video List
          Expanded(
            child: Obx(() => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.videos.length,
                itemBuilder: (context, index) {
                  final v = controller.videos[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.only(bottom: 16),
                    leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(v.thumbnail,
                            width: 100, height: 60, fit: BoxFit.cover)),
                    title: Text(v.title,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: const Text('YouTube',
                        style: TextStyle(color: Colors.white54, fontSize: 12)),
                    trailing: IconButton(
                        icon: const Icon(Icons.play_arrow,
                            color: Color(0xFFFF8906)),
                        onPressed: () => controller.playVideo(v)),
                  );
                })),
          ),
        ],
      ),
    );
  }
}
