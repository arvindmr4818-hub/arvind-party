enum AgencyRole { owner, director, manager, recruiter, host, trainee }

class AgencyMemberModel {
  final String hostId;
  final String username;
  final String avatar;
  final int level;
  final String country;
  final AgencyRole role;
  final double monthlyRevenueGenerated;
  final double targetProgressPercentage;
  final double onlineHoursThisMonth;
  final DateTime contractSignedAt;
  final bool isCurrentlyBroadcasting;

  const AgencyMemberModel({
    required this.hostId,
    required this.username,
    required this.avatar,
    required this.level,
    required this.country,
    required this.role,
    this.monthlyRevenueGenerated = 0.0,
    this.targetProgressPercentage = 0.0,
    this.onlineHoursThisMonth = 0.0,
    required this.contractSignedAt,
    this.isCurrentlyBroadcasting = false,
  });

  factory AgencyMemberModel.fromJson(Map<String, dynamic> json) {
    return AgencyMemberModel(
      hostId: json['hostId'] ?? '',
      username: json['username'] ?? '',
      avatar: json['avatar'] ?? '',
      level: json['level'] ?? 1,
      country: json['country'] ?? 'Global',
      role: AgencyRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => AgencyRole.host,
      ),
      monthlyRevenueGenerated:
          (json['monthlyRevenueGenerated'] ?? 0.0).toDouble(),
      targetProgressPercentage:
          (json['targetProgressPercentage'] ?? 0.0).toDouble(),
      onlineHoursThisMonth: (json['onlineHoursThisMonth'] ?? 0.0).toDouble(),
      contractSignedAt: json['contractSignedAt'] != null
          ? DateTime.parse(json['contractSignedAt'])
          : DateTime.now(),
      isCurrentlyBroadcasting: json['isCurrentlyBroadcasting'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostId': hostId,
      'username': username,
      'avatar': avatar,
      'level': level,
      'country': country,
      'role': role.toString().split('.').last,
      'monthlyRevenueGenerated': monthlyRevenueGenerated,
      'targetProgressPercentage': targetProgressPercentage,
      'onlineHoursThisMonth': onlineHoursThisMonth,
      'contractSignedAt': contractSignedAt.toIso8601String(),
      'isCurrentlyBroadcasting': isCurrentlyBroadcasting,
    };
  }
}
