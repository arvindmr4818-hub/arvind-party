enum FamilyRole {
  owner,
  coOwner,
  manager,
  elder,
  vip,
  member,
}

class FamilyMemberModel {
  final String userId;
  final String name;
  final String avatar;
  final int userLevel;
  final FamilyRole role;
  final int dynamicContribution; // Total history points given to family
  final int todayContribution; // Points generated during current 24-hr loop
  final DateTime joinedAt;
  final bool isOnline;

  const FamilyMemberModel({
    required this.userId,
    required this.name,
    required this.avatar,
    required this.userLevel,
    required this.role,
    this.dynamicContribution = 0,
    this.todayContribution = 0,
    required this.joinedAt,
    this.isOnline = false,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      userLevel: json['userLevel'] ?? 1,
      role: FamilyRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => FamilyRole.member,
      ),
      dynamicContribution: json['dynamicContribution'] ?? 0,
      todayContribution: json['todayContribution'] ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'])
          : DateTime.now(),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'avatar': avatar,
      'userLevel': userLevel,
      'role': role.toString().split('.').last,
      'dynamicContribution': dynamicContribution,
      'todayContribution': todayContribution,
      'joinedAt': joinedAt.toIso8601String(),
      'isOnline': isOnline,
    };
  }

  FamilyMemberModel copyWith({
    String? userId,
    String? name,
    String? avatar,
    int? userLevel,
    FamilyRole? role,
    int? dynamicContribution,
    int? todayContribution,
    DateTime? joinedAt,
    bool? isOnline,
  }) {
    return FamilyMemberModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      userLevel: userLevel ?? this.userLevel,
      role: role ?? this.role,
      dynamicContribution: dynamicContribution ?? this.dynamicContribution,
      todayContribution: todayContribution ?? this.todayContribution,
      joinedAt: joinedAt ?? this.joinedAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
