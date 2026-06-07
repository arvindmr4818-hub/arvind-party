// lib/shared/models/notification_model.dart
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'follow', 'gift', 'room_invite', 'system', 'agency', 'family'
  final String? senderId;
  final String? senderName;
  final String? senderAvatar;
  final String? targetId;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.senderId,
    this.senderName,
    this.senderAvatar,
    this.targetId,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      senderId: json['senderId']?.toString(),
      senderName: json['senderName']?.toString(),
      senderAvatar: json['senderAvatar']?.toString(),
      targetId: json['targetId']?.toString(),
      isRead: json['isRead'] is bool ? json['isRead'] : false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'senderId': senderId,
        'senderName': senderName,
        'senderAvatar': senderAvatar,
        'targetId': targetId,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        'data': data,
      };
}
