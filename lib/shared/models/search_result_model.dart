// lib/shared/models/search_result_model.dart
class SearchResultModel {
  final String id;
  final String type; // 'user', 'room', 'agency', 'family', 'gift'
  final String title;
  final String subtitle;
  final String imageUrl;
  final Map<String, dynamic>? extra;

  SearchResultModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.extra,
  });

  factory SearchResultModel.fromJson(Map<String, dynamic> json) {
    return SearchResultModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'user',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      extra: json['extra'] is Map ? Map<String, dynamic>.from(json['extra']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'subtitle': subtitle,
        'imageUrl': imageUrl,
        'extra': extra,
      };
}
