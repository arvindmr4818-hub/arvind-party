// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/youtube/presentation/views/youtube_room_screen.dart
// ARVIND PARTY - YOUTUBE ROOM SCREEN (Host shares video, synchronized playback)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/youtube_controller.dart';

class YouTubeRoomScreen extends GetView<YouTubeController> {
  const YouTubeRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        title: const Text('YouTube Room', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF15141F),
        actions: [
          Obx(() => Switch(value: controller.synchronizedPlayback.value, onChanged: (_) => controller.toggleWatchParty(), activeColor: const Color(0xFFFF8906))),
          const Padding(padding: EdgeInsets.only(right: 8), child: Text('Sync', style: TextStyle(color: Colors.grey, fontSize: 12))),
        ],
      ),
      body: Column(children: [
        Obx(() {
          if (controller.currentVideo.value == null) {
            return Container(height: 220, color: Colors.black, child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 8), const Text('Search & play a video', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8), ElevatedButton.icon(onPressed: () => _showSearchDialog(context), icon: const Icon(Icons.search), label: const Text('Search YouTube'), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906))),
            ])));
          }
          final video = controller.currentVideo.value!;
          return Container(height: 220, color: Colors.black, child: Stack(fit: StackFit.expand, children: [
            Image.network(video.thumbnailUrl, fit: BoxFit.cover),
            Container(color: Colors.black.withValues(alpha: 0.4)),
            Center(child: Obx(() => IconButton(iconSize: 64, icon: Icon(controller.isPlaying.value ? Icons.pause_circle : Icons.play_circle, color: Colors.white), onPressed: controller.togglePlayPause))),
            Positioned(bottom: 0, left: 0, right: 0, child: Obx(() => Slider(value: controller.currentPosition.value, max: controller.videoDuration.value > 0 ? controller.videoDuration.value : 1, onChanged: controller.seekTo, activeColor: const Color(0xFFFF8906)))),
            Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)), child: Text(video.title, style: const TextStyle(color: Colors.white, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis))),
          ]));
        }),
        Obx(() {
          final video = controller.currentVideo.value;
          if (video == null) return const SizedBox();
          return Container(padding: const EdgeInsets.all(12), child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(video.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2),
              const SizedBox(height: 4), Text(video.channelName ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ])),
            IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white70), onPressed: controller.playPrevious),
            Obx(() => IconButton(icon: Icon(controller.isPlaying.value ? Icons.pause : Icons.play_arrow, color: Colors.white), onPressed: controller.togglePlayPause)),
            IconButton(icon: const Icon(Icons.skip_next, color: Colors.white70), onPressed: controller.playNext),
          ]));
        }),
        Expanded(child: Obx(() {
          if (controller.playlist.isEmpty) return const Center(child: Text('No videos in playlist', style: TextStyle(color: Colors.grey)));
          return ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 12), itemCount: controller.playlist.length, itemBuilder: (context, index) {
            final video = controller.playlist[index];
            final isCurrent = controller.currentVideo.value?.id == video.id;
            return Card(color: isCurrent ? const Color(0xFF2D2D44) : const Color(0xFF1A1A2E), child: ListTile(
              leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(video.thumbnailUrl, width: 80, height: 45, fit: BoxFit.cover)),
              title: Text(video.title, style: TextStyle(color: isCurrent ? const Color(0xFFFF8906) : Colors.white, fontSize: 13), maxLines: 2),
              subtitle: Text(video.channelName ?? '', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              trailing: Obx(() => isCurrent ? Icon(controller.isPlaying.value ? Icons.equalizer : Icons.play_arrow, color: const Color(0xFFFF8906)) : IconButton(icon: const Icon(Icons.playlist_play, color: Colors.white54), onPressed: () => controller.playVideo(video))),
              onTap: () => controller.playVideo(video),
            ));
          });
        })),
      ]),
      floatingActionButton: FloatingActionButton(backgroundColor: const Color(0xFFFF8906), child: const Icon(Icons.add), onPressed: () => _showSearchDialog(context)),
    );
  }

  void _showSearchDialog(BuildContext context) {
    final searchCtrl = TextEditingController();
    Get.dialog(AlertDialog(backgroundColor: const Color(0xFF1A1A2E), title: const Text('Search YouTube', style: TextStyle(color: Colors.white)), content: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: searchCtrl, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Search videos...', hintStyle: const TextStyle(color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), prefixIcon: const Icon(Icons.search, color: Colors.white54))),
      const SizedBox(height: 16),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { if (searchCtrl.text.isNotEmpty) { controller.searchVideos(searchCtrl.text); Get.back(); } }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8906)), child: const Text('Search', style: TextStyle(color: Colors.white)))),
    ])));
  }
}