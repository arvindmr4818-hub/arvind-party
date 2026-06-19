// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/youtube/models/youtube_video_model.dart
// ARVIND PARTY - YOUTUBE VIDEO MODEL
// ═══════════════════════════════════════════════════════════════════════════

class YouTubeVideo {
  final String id;
  final String title;
  final String? description;
  final String thumbnailUrl;
  final String videoUrl;
  final String? channelName;
  final double? duration;
  final int? views;

  YouTubeVideo({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    this.channelName,
    this.duration,
    this.views,
  });

  factory YouTubeVideo.fromJson(Map<String, dynamic> json) => YouTubeVideo(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'],
    thumbnailUrl: json['thumbnailUrl'] ?? json['thumbnail'] ?? '',
    videoUrl: json['videoUrl'] ?? '',
    channelName: json['channelName'] ?? json['channel'] ?? '',
    duration: (json['duration'] ?? 0).toDouble(),
    views: json['views'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'videoUrl': videoUrl,
    'channelName': channelName,
    'duration': duration,
    'views': views,
  };
}