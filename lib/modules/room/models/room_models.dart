import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════
// 1. LIVE CHAT MESSAGE MODEL
// ═══════════════════════════════════════════════════════════════════════════
class ChatMessage {
  final String messageId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String message;
  final bool isVip;
  final DateTime timestamp;

  ChatMessage({
    required this.messageId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.message,
    this.isVip = false,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? 'Guest',
      senderAvatar: json['senderAvatar']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      isVip: json['isVip'] ?? false,
      timestamp: DateTime.now(), // Sockets are real-time, so current time is perfect
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 2. MIC SEAT MANAGEMENT MODEL
// ═══════════════════════════════════════════════════════════════════════════
class Seat {
  final int seatIndex;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final bool isMuted;
  final bool isLocked;

  Seat({
    required this.seatIndex,
    this.userId,
    this.userName,
    this.userAvatar,
    this.isMuted = true,
    this.isLocked = false,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      seatIndex: (json['seatIndex'] as int?) ?? 0,
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      userAvatar: json['userAvatar']?.toString(),
      isMuted: json['isMuted'] ?? true,
      isLocked: json['isLocked'] ?? false,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// 3. REAL-TIME GIFT ANIMATION MODEL
// ═══════════════════════════════════════════════════════════════════════════
class GiftAnimation {
  final String giftId;
  final String giftImageUrl; // For SVGA / Lightweight Lottie animations
  final String senderName;
  final int quantity;

  GiftAnimation({
    required this.giftId,
    required this.giftImageUrl,
    required this.senderName,
    required this.quantity,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// 4. MAIN ROOM ENVIRONMENT MASTER MODEL
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
        title: json['title']?.toString() ?? json['name']?.toString() ?? '', // Backend mapping sync fallback
        topic: json['topic']?.toString() ?? '',
        banner: json['banner']?.toString() ?? json['coverImage']?.toString() ?? '', // Safe validation wrapper
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