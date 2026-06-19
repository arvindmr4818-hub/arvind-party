// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/youtube/presentation/repositories/youtube_repository.dart
// ARVIND PARTY - YOUTUBE REPOSITORY (Mock)
// ═══════════════════════════════════════════════════════════════════════════

import '../../models/youtube_video_model.dart';

class YouTubeRepository {
  Future<List<YouTubeVideo>> getPlaylist() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockVideos();
  }

  Future<List<YouTubeVideo>> searchVideos(String query) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockVideos().where((v) =>
      v.title.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<YouTubeVideo?> getVideoDetails(String videoId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final videos = _mockVideos();
    try {
      return videos.firstWhere((v) => v.id == videoId);
    } catch (_) {
      return null;
    }
  }

  List<YouTubeVideo> _mockVideos() => [
    YouTubeVideo(id: 'yt1', title: 'Party Music Mix 2024', thumbnailUrl: 'https://picsum.photos/seed/music/320/180', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', channelName: 'Party Central', duration: 240.0, views: 15000),
    YouTubeVideo(id: 'yt2', title: 'Live DJ Session', thumbnailUrl: 'https://picsum.photos/seed/dj/320/180', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', channelName: 'DJ Arvind', duration: 3600.0, views: 42000),
    YouTubeVideo(id: 'yt3', title: 'Karaoke Hits Collection', thumbnailUrl: 'https://picsum.photos/seed/karaoke/320/180', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', channelName: 'Sing Along', duration: 1800.0, views: 28000),
    YouTubeVideo(id: 'yt4', title: 'Romantic Songs Night', thumbnailUrl: 'https://picsum.photos/seed/romantic/320/180', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', channelName: 'Love Songs', duration: 1200.0, views: 35000),
    YouTubeVideo(id: 'yt5', title: 'Dance Floor Fillers', thumbnailUrl: 'https://picsum.photos/seed/dance/320/180', videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', channelName: 'Dance Crew', duration: 900.0, views: 22000),
  ];
}