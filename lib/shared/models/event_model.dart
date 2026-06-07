// lib/shared/models/event_model.dart
class AppEventModel {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int rewardCoins;
  final String type; // 'party', 'agency', 'family', 'global'
  final bool isActive;

  AppEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.startDate,
    required this.endDate,
    required this.rewardCoins,
    required this.type,
    required this.isActive,
  });

  factory AppEventModel.fromJson(Map<String, dynamic> json) {
    return AppEventModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverUrl: json['coverUrl']?.toString() ?? '',
      startDate: DateTime.tryParse(json['startDate']?.toString() ?? '') ?? DateTime.now(),
      endDate: DateTime.tryParse(json['endDate']?.toString() ?? '') ?? DateTime.now().add(const Duration(days: 7)),
      rewardCoins: json['rewardCoins'] is int ? json['rewardCoins'] : int.tryParse(json['rewardCoins']?.toString() ?? '0') ?? 0,
      type: json['type']?.toString() ?? 'global',
      isActive: json['isActive'] is bool ? json['isActive'] : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'coverUrl': coverUrl,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'rewardCoins': rewardCoins,
        'type': type,
        'isActive': isActive,
      };
}
