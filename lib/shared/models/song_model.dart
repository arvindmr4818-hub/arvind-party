// lib/shared/models/song_model.dart
class SongModel {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String audioUrl;
  final int duration;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.audioUrl,
    required this.duration,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown',
      artist: json['artist']?.toString() ?? 'Unknown',
      coverUrl: json['coverUrl']?.toString() ?? '',
      audioUrl: json['audioUrl']?.toString() ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'coverUrl': coverUrl,
      'audioUrl': audioUrl,
      'duration': duration,
    };
  }
}
