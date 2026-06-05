// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/models/room_model.dart
// ═══════════════════════════════════════════════════════════════════════════

class RoomModel {
  final String id;
  final String title;
  final String topic;
  final String banner;
  final String welcomeMessage;
  final String announcement;
  final String? pinnedMessage;
  final String roomType; // public / private / password
  final String? password;
  final int seatCount; // 8 / 10 / 15 / 20 / 25
  final int onlineUsers;
  final String hostId;

  const RoomModel({
    required this.id,
    required this.title,
    required this.topic,
    required this.banner,
    required this.welcomeMessage,
    required this.announcement,
    this.pinnedMessage,
    required this.roomType,
    this.password,
    required this.seatCount,
    required this.onlineUsers,
    required this.hostId,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        title: json['title']?.toString() ?? '',
        topic: json['topic']?.toString() ?? '',
        banner: json['banner']?.toString() ?? '',
        welcomeMessage: json['welcomeMessage']?.toString() ?? '',
        announcement: json['announcement']?.toString() ?? '',
        pinnedMessage: json['pinnedMessage']?.toString(),
        roomType: json['roomType']?.toString() ?? 'public',
        password: json['password']?.toString(),
        seatCount: (json['seatCount'] as int?) ?? 8,
        onlineUsers: (json['onlineUsers'] as int?) ?? 0,
        hostId: json['hostId']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'topic': topic,
        'banner': banner,
        'welcomeMessage': welcomeMessage,
        'announcement': announcement,
        'pinnedMessage': pinnedMessage,
        'roomType': roomType,
        'password': password,
        'seatCount': seatCount,
        'onlineUsers': onlineUsers,
        'hostId': hostId,
      };

  RoomModel copyWith({
    String? id,
    String? title,
    String? topic,
    String? banner,
    String? welcomeMessage,
    String? announcement,
    String? pinnedMessage,
    String? roomType,
    String? password,
    int? seatCount,
    int? onlineUsers,
    String? hostId,
  }) =>
      RoomModel(
        id: id ?? this.id,
        title: title ?? this.title,
        topic: topic ?? this.topic,
        banner: banner ?? this.banner,
        welcomeMessage: welcomeMessage ?? this.welcomeMessage,
        announcement: announcement ?? this.announcement,
        pinnedMessage: pinnedMessage ?? this.pinnedMessage,
        roomType: roomType ?? this.roomType,
        password: password ?? this.password,
        seatCount: seatCount ?? this.seatCount,
        onlineUsers: onlineUsers ?? this.onlineUsers,
        hostId: hostId ?? this.hostId,
      );
}
