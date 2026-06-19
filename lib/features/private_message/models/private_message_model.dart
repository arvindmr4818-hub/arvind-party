import 'package:intl/intl.dart';

class PrivateMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final String messageType; // text, image, voice, video, file
  final String? mediaUrl;
  final String? fileName;
  final int? fileSizeBytes;
  final double? durationSeconds; // for voice/video
  final bool isRead;
  final DateTime readAt;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final bool isDeleted;

  PrivateMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.fileName,
    this.fileSizeBytes,
    this.durationSeconds,
    this.isRead = false,
    DateTime? readAt,
    this.isEdited = false,
    required this.createdAt,
    this.editedAt,
    this.deletedAt,
    this.isDeleted = false,
  }) : readAt = readAt ?? DateTime.now();

  factory PrivateMessage.fromJson(Map<String, dynamic> json) {
    return PrivateMessage(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      recipientId: json['recipientId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      mediaUrl: json['mediaUrl'],
      fileName: json['fileName'],
      fileSizeBytes: json['fileSizeBytes'],
      durationSeconds: (json['durationSeconds'] as num?)?.toDouble(),
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'])
          : DateTime.now(),
      isEdited: json['isEdited'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      isDeleted: json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientId': recipientId,
      'content': content,
      'messageType': messageType,
      'mediaUrl': mediaUrl,
      'fileName': fileName,
      'fileSizeBytes': fileSizeBytes,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String getTimeString() {
    return DateFormat('HH:mm').format(createdAt);
  }

  String getDateString() {
    return DateFormat('dd/MM/yyyy').format(createdAt);
  }
}

class UserStatus {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String? currentActivity;
  final bool isTyping;

  UserStatus({
    required this.userId,
    this.isOnline = false,
    this.lastSeenAt,
    this.currentActivity,
    this.isTyping = false,
  });

  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      userId: json['userId'] ?? '',
      isOnline: json['isOnline'] ?? false,
      lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt']) : null,
      currentActivity: json['currentActivity'],
      isTyping: json['isTyping'] ?? false,
    );
  }

  String getStatusText() {
    if (isOnline) return 'Online';
    if (lastSeenAt == null) return 'Never';

    final now = DateTime.now();
    final difference = now.difference(lastSeenAt!);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    return '${difference.inDays}d ago';
  }
}

class PrivateChatUser {
  final String userId;
  final String username;
  final String? avatar;
  final String? bio;
  final UserStatus status;
  final DateTime? lastMessageTime;
  final int unreadCount;

  PrivateChatUser({
    required this.userId,
    required this.username,
    this.avatar,
    this.bio,
    required this.status,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory PrivateChatUser.fromJson(Map<String, dynamic> json) {
    return PrivateChatUser(
      userId: json['userId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      status: UserStatus.fromJson(json['status'] ?? {}),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.parse(json['lastMessageTime'])
          : null,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}