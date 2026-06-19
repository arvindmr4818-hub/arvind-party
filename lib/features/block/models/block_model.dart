enum MuteDuration { fifteenMinutes, oneHour, sixHours, oneDay, oneWeek, forever }

class BlockedUserModel {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime blockedAt;

  BlockedUserModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.blockedAt,
  });

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) => BlockedUserModel(
    userId: json['userId'] ?? '',
    username: json['username'] ?? 'Unknown',
    avatarUrl: json['avatarUrl'],
    blockedAt: DateTime.parse(json['blockedAt']),
  );
}

class MutedUserModel {
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime mutedAt;
  final DateTime? mutedUntil;

  MutedUserModel({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.mutedAt,
    this.mutedUntil,
  });

  bool get isActive => mutedUntil == null || DateTime.now().isBefore(mutedUntil!);

  factory MutedUserModel.fromJson(Map<String, dynamic> json) => MutedUserModel(
    userId: json['userId'] ?? '',
    username: json['username'] ?? 'Unknown',
    avatarUrl: json['avatarUrl'],
    mutedAt: DateTime.parse(json['mutedAt']),
    mutedUntil: json['mutedUntil'] != null ? DateTime.parse(json['mutedUntil']) : null,
  );
}