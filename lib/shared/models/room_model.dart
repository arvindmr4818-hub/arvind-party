// lib/shared/models/room_model.dart
class RoomModel {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final String hostAvatar;
  final String coverImage;
  final String description;
  final String category;
  final int viewers;
  final bool isLive;
  final bool isVip;
  final bool isPk;
  final List<String> tags;
  final DateTime? startedAt;
  final String? type; // 'voice', 'video'

  RoomModel({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    required this.hostAvatar,
    required this.coverImage,
    required this.description,
    required this.category,
    required this.viewers,
    required this.isLive,
    required this.isVip,
    required this.isPk,
    required this.tags,
    this.startedAt,
    this.type,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? '').toString(),
      hostId: (json['hostId'] ?? json['host_id'] ?? '').toString(),
      hostName: (json['host'] ?? json['hostName'] ?? '').toString(),
      hostAvatar: (json['hostAvatar'] ?? json['host_avatar'] ?? '').toString(),
      coverImage: (json['coverImage'] ?? json['cover'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      category: (json['category'] ?? 'All').toString(),
      viewers: (json['viewers'] as num?)?.toInt() ?? 0,
      isLive: json['isLive'] is bool ? json['isLive'] : true,
      isVip: json['isVip'] is bool ? json['isVip'] : false,
      isPk: json['isPk'] is bool ? json['isPk'] : false,
      tags: (json['tags'] is List) ? List<String>.from(json['tags'].map((e) => e.toString())) : <String>[],
      startedAt: json['startedAt'] != null ? DateTime.tryParse(json['startedAt'].toString()) : null,
      type: (json['type'] ?? 'voice').toString(),
    );
  }

  factory RoomModel.fromMap(Map<String, dynamic> map) => RoomModel.fromJson(map);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hostId': hostId,
        'hostName': hostName,
        'hostAvatar': hostAvatar,
        'coverImage': coverImage,
        'description': description,
        'category': category,
        'viewers': viewers,
        'isLive': isLive,
        'isVip': isVip,
        'isPk': isPk,
        'tags': tags,
        'startedAt': startedAt?.toIso8601String(),
        'type': type,
      };
}
