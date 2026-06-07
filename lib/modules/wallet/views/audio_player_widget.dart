import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'audio_player_controller.dart';

class AudioPlayerWidget extends StatelessWidget {
  const AudioPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AudioPlayerController());

    return Obx(() {
      final song = controller.currentSong.value;
      if (song == null) return const SizedBox();

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFFF8906).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1),
            ]),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: Color(0xFFFF8906), shape: BoxShape.circle),
              child:
                  const Icon(Icons.music_note, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(song.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(song.artist,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
                icon: Icon(
                    controller.isPlaying.value
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: Colors.white,
                    size: 36),
                onPressed: controller.togglePlay),
            IconButton(
                icon: const Icon(Icons.skip_next,
                    color: Colors.white54, size: 28),
                onPressed: controller.nextSong),
          ],
        ),
      );
    });
  }
}
