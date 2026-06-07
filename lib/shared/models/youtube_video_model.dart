// lib/shared/models/youtube_video_model.dart
class YoutubeVideoModel {
  final String id;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;
  final String videoUrl;
  final int duration; // seconds
  final int views;
  final String? description;

  YoutubeVideoModel({
    required this.id,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.views,
    this.description,
  });

  factory YoutubeVideoModel.fromJson(Map<String, dynamic> json) {
    return YoutubeVideoModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      channelTitle: json['channelTitle']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      views: json['views'] is int ? json['views'] : int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'channelTitle': channelTitle,
        'thumbnailUrl': thumbnailUrl,
        'videoUrl': videoUrl,
        'duration': duration,
        'views': views,
        'description': description,
      };
}
