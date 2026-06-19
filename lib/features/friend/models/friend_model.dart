enum FriendStatus { none, following, follower, friends, pendingIncoming, pendingOutgoing }

class FriendModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final FriendStatus status;
  final int mutualFriendsCount;
  final bool isOnline;
  final DateTime? lastSeen;

  FriendModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.status,
    this.mutualFriendsCount = 0,
    this.isOnline = false,
    this.lastSeen,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    id: json['id'] ?? '',
    username: json['username'] ?? 'Unknown',
    avatarUrl: json['avatarUrl'],
    status: FriendStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => FriendStatus.none),
    mutualFriendsCount: json['mutualFriendsCount'] ?? 0,
    isOnline: json['isOnline'] ?? false,
    lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
  );
}

class FriendRequestModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final DateTime createdAt;

  FriendRequestModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) => FriendRequestModel(
    id: json['id'] ?? '',
    senderId: json['senderId'] ?? '',
    senderName: json['senderName'] ?? 'Unknown',
    senderAvatar: json['senderAvatar'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}