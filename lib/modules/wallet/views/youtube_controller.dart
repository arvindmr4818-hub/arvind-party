import 'package:get/get.dart';
import '../models/youtube_video_model.dart';

class YoutubeController extends GetxController {
  final videos = <YoutubeVideoModel>[].obs;
  final currentVideo = Rxn<YoutubeVideoModel>();
  final isPlaying = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVideos();
  }

  void _loadVideos() {
    // Placeholder data - Later fetch from your backend or YouTube Data API
    videos.assignAll([
      YoutubeVideoModel(
          id: '1',
          title: 'Top Hits 2024 - Live Mix',
          thumbnail: 'https://picsum.photos/seed/yt1/300/200',
          videoId: 'dQw4w9WgXcQ'),
      YoutubeVideoModel(
          id: '2',
          title: 'Funny Moments Compilation',
          thumbnail: 'https://picsum.photos/seed/yt2/300/200',
          videoId: 'jNQXAC9IVRw'),
      YoutubeVideoModel(
          id: '3',
          title: 'Horror Game Live Stream',
          thumbnail: 'https://picsum.photos/seed/yt3/300/200',
          videoId: 'xyz123'),
    ]);
  }

  void playVideo(YoutubeVideoModel video) {
    currentVideo.value = video;
    isPlaying.value = true;
    // TODO: Initialize youtube_player_flutter controller here and sync with socket
    // socketService.emit('youtube_play', {'videoId': video.videoId});
  }
}
