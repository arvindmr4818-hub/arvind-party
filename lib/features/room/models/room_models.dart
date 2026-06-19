// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/models/room_models.dart
// ARVIND PARTY - ROOM MODELS
// ═══════════════════════════════════════════════════════════════════════════

class RoomModel {
  final String id;
  final String name;
  final String? title;
  final String hostId;
  final String? hostName;
  final int maxMembers;
  final int currentMembers;
  final int onlineUsers;
  final int seatCount;
  final bool isLive;
  final String? roomPassword;
  final String? password;
  final String? roomType;
  final String? topic;
  final String? banner;
  final List<String> tags;
  final String? pinnedMessage;
  final String? announcement;
  final String? welcomeMessage;

  RoomModel({
    required this.id,
    required this.name,
    this.title,
    required this.hostId,
    this.hostName,
    this.maxMembers = 10,
    this.currentMembers = 0,
    this.onlineUsers = 0,
    this.seatCount = 10,
    this.isLive = false,
    this.roomPassword,
    this.password,
    this.roomType,
    this.topic,
    this.banner,
    this.tags = const [],
    this.pinnedMessage,
    this.announcement,
    this.welcomeMessage,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      title: json['title'] ?? json['name'],
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'],
      maxMembers: json['maxMembers'] ?? 10,
      currentMembers: json['currentMembers'] ?? 0,
      onlineUsers: json['onlineUsers'] ?? 0,
      seatCount: json['seatCount'] ?? 10,
      isLive: json['isLive'] ?? false,
      roomPassword: json['roomPassword'],
      password: json['password'],
      roomType: json['roomType'],
      topic: json['topic'],
      banner: json['banner'],
      tags: List<String>.from(json['tags'] ?? []),
      pinnedMessage: json['pinnedMessage'],
      announcement: json['announcement'],
      welcomeMessage: json['welcomeMessage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'title': title,
    'hostId': hostId,
    'hostName': hostName,
    'maxMembers': maxMembers,
    'currentMembers': currentMembers,
    'onlineUsers': onlineUsers,
    'seatCount': seatCount,
    'isLive': isLive,
    'roomPassword': roomPassword,
    'password': password,
    'roomType': roomType,
    'topic': topic,
    'banner': banner,
    'tags': tags,
    'pinnedMessage': pinnedMessage,
    'announcement': announcement,
    'welcomeMessage': welcomeMessage,
  };

  RoomModel copyWith({
    String? id,
    String? name,
    String? title,
    String? hostId,
    String? hostName,
    int? maxMembers,
    int? currentMembers,
    int? onlineUsers,
    int? seatCount,
    bool? isLive,
    String? roomPassword,
    String? password,
    String? roomType,
    String? topic,
    String? banner,
    List<String>? tags,
    String? pinnedMessage,
    String? announcement,
    String? welcomeMessage,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      maxMembers: maxMembers ?? this.maxMembers,
      currentMembers: currentMembers ?? this.currentMembers,
      onlineUsers: onlineUsers ?? this.onlineUsers,
      seatCount: seatCount ?? this.seatCount,
      isLive: isLive ?? this.isLive,
      roomPassword: roomPassword ?? this.roomPassword,
      password: password ?? this.password,
      roomType: roomType ?? this.roomType,
      topic: topic ?? this.topic,
      banner: banner ?? this.banner,
      tags: tags ?? this.tags,
      pinnedMessage: pinnedMessage ?? this.pinnedMessage,
      announcement: announcement ?? this.announcement,
      welcomeMessage: welcomeMessage ?? this.welcomeMessage,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String message;
  final String time;
  final bool isMe;
  final String? senderAvatar;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.time,
    this.isMe = false,
    this.senderAvatar,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      message: json['message']?.toString() ?? json['text']?.toString() ?? '',
      time: json['time']?.toString() ?? json['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
      isMe: json['isMe'] ?? false,
      senderAvatar: json['senderAvatar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'time': time,
    'isMe': isMe,
    'senderAvatar': senderAvatar,
  };
}

class RaiseHandRequest {
  final String requestId;
  final String userId;
  final String userName;
  final String? avatar;
  final DateTime requestedAt;

  RaiseHandRequest({
    required this.requestId,
    required this.userId,
    required this.userName,
    this.avatar,
    required this.requestedAt,
  });
}

enum MemberRole {
  host,
  coHost,
  moderator,
  speaker,
  listener,
  muted,
  visitor,
  owner,
  admin,
  member,
}

class RoomMemberModel {
  final String id;
  final String userId;
  final String userName;
  final MemberRole role;
  final bool isOnline;
  final String? avatar;
  final int? userLevel;

  const RoomMemberModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.role,
    this.isOnline = false,
    this.avatar,
    this.userLevel,
  });

  RoomMemberModel copyWith({
    String? id,
    String? userId,
    String? userName,
    MemberRole? role,
    bool? isOnline,
    String? avatar,
    int? userLevel,
  }) {
    return RoomMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      role: role ?? this.role,
      isOnline: isOnline ?? this.isOnline,
      avatar: avatar ?? this.avatar,
      userLevel: userLevel ?? this.userLevel,
    );
  }
}

class SeatModel {
  final int index;
  final String? userId;
  final String? userName;
  final String? avatar;
  final bool isOccupied;
  final bool isLocked;
  final bool isMuted;

  const SeatModel({
    required this.index,
    this.userId,
    this.userName,
    this.avatar,
    this.isOccupied = false,
    this.isLocked = false,
    this.isMuted = false,
  });

  String get seatNumber => '${index + 1}';

  bool get isHost => userId == 'host';

  bool get isSpeaking => false;

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      index: json['index'] ?? 0,
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      avatar: json['avatar']?.toString(),
      isOccupied: json['isOccupied'] ?? false,
      isLocked: json['isLocked'] ?? false,
      isMuted: json['isMuted'] ?? false,
    );
  }

  SeatModel copyWith({
    int? index,
    String? userId,
    String? userName,
    String? avatar,
    bool? isOccupied,
    bool? isLocked,
    bool? isMuted,
  }) {
    return SeatModel(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      avatar: avatar ?? this.avatar,
      isOccupied: isOccupied ?? this.isOccupied,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
    );
  }
}

class RoomPermissionModel {
  final bool canSpeak;
  final bool canShareVideo;
  final bool canSendGifts;
  final bool canChat;
  final bool canInvite;

  const RoomPermissionModel({
    this.canSpeak = true,
    this.canShareVideo = false,
    this.canSendGifts = true,
    this.canChat = true,
    this.canInvite = false,
  });

  factory RoomPermissionModel.forRole(MemberRole role) {
    switch (role) {
      case MemberRole.host:
      case MemberRole.coHost:
      case MemberRole.admin:
        return const RoomPermissionModel(canSpeak: true, canShareVideo: true, canSendGifts: true, canChat: true, canInvite: true);
      case MemberRole.moderator:
        return const RoomPermissionModel(canSpeak: true, canShareVideo: false, canSendGifts: true, canChat: true, canInvite: false);
      case MemberRole.speaker:
        return const RoomPermissionModel(canSpeak: true, canShareVideo: true, canSendGifts: true, canChat: true, canInvite: false);
      case MemberRole.listener:
      case MemberRole.muted:
      case MemberRole.visitor:
      case MemberRole.member:
      default:
        return const RoomPermissionModel(canSpeak: false, canShareVideo: false, canSendGifts: false, canChat: true, canInvite: false);
    }
  }
}

class SeatData {
  final int index;
  final String? userId;
  final String? userName;
  final String? userAvatar;
  final bool isLocked;
  final bool isMuted;
  final String role;

  const SeatData({
    required this.index,
    this.userId,
    this.userName,
    this.userAvatar,
    this.isLocked = false,
    this.isMuted = false,
    this.role = 'empty',
  });

  bool get isOccupied => userId != null && userId!.isNotEmpty;

  factory SeatData.fromJson(Map<String, dynamic> json) {
    return SeatData(
      index: json['index'] ?? 0,
      userId: json['userId']?.toString(),
      userName: json['userName']?.toString(),
      userAvatar: json['userAvatar']?.toString() ?? json['avatar']?.toString(),
      isLocked: json['isLocked'] ?? false,
      isMuted: json['isMuted'] ?? false,
      role: json['role']?.toString() ?? 'empty',
    );
  }

  Map<String, dynamic> toJson() => {
    'index': index,
    'userId': userId,
    'userName': userName,
    'userAvatar': userAvatar,
    'isLocked': isLocked,
    'isMuted': isMuted,
    'role': role,
  };

  SeatData copyWith({
    int? index,
    String? userId,
    String? userName,
    String? userAvatar,
    bool? isLocked,
    bool? isMuted,
    String? role,
  }) {
    return SeatData(
      index: index ?? this.index,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      isLocked: isLocked ?? this.isLocked,
      isMuted: isMuted ?? this.isMuted,
      role: role ?? this.role,
    );
  }
}

class GiftAnimation {
  final String giftId;
  final String giftName;
  final String senderName;
  final String? animationUrl;
  final String? giftImageUrl;
  final int quantity;

  const GiftAnimation({
    required this.giftId,
    this.giftName = 'Gift',
    required this.senderName,
    this.animationUrl,
    this.giftImageUrl,
    this.quantity = 1,
  });

  factory GiftAnimation.fromJson(Map<String, dynamic> json) {
    return GiftAnimation(
      giftId: json['giftId']?.toString() ?? '',
      giftName: json['giftName']?.toString() ?? 'Gift',
      senderName: json['giftName']?.toString() ?? 'Unknown',
      animationUrl: json['animationUrl']?.toString(),
      giftImageUrl: json['giftImageUrl']?.toString(),
      quantity: json['quantity'] ?? 1,
    );
  }

  GiftAnimation copyWith({
    String? giftId,
    String? giftName,
    String? senderName,
    String? animationUrl,
    String? giftImageUrl,
    int? quantity,
  }) {
    return GiftAnimation(
      giftId: giftId ?? this.giftId,
      giftName: giftName ?? this.giftName,
      senderName: senderName ?? this.senderName,
      animationUrl: animationUrl ?? this.animationUrl,
      giftImageUrl: giftImageUrl ?? this.giftImageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}