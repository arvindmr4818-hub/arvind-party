class YoutubeVideoModel {
  final String id;
  final String title;
  final String thumbnail;
  final String videoId; // The actual YouTube Video ID

  YoutubeVideoModel({
    required this.id,
    required this.title,
    required this.thumbnail,
    required this.videoId,
  });
}
