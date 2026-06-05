class FamilyModel {
  final String id;
  final String name;
  final String logo;
  final String banner;
  final String description;
  final String notice; // Pinned message for announcement boards
  final int level;
  final int points;
  final int currentExp;
  final int nextLevelExp;
  final int membersCount;
  final int maxMembersLimit;
  final String ownerId;
  final String ownerName;
  final double todayRankingPoints;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.logo,
    required this.banner,
    required this.description,
    required this.notice,
    required this.level,
    required this.points,
    required this.currentExp,
    required this.nextLevelExp,
    required this.membersCount,
    required this.maxMembersLimit,
    required this.ownerId,
    required this.ownerName,
    this.todayRankingPoints = 0.0,
  });

  factory FamilyModel.fromJson(Map<String, dynamic> json) {
    return FamilyModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      banner: json['banner'] ?? '',
      description: json['description'] ?? '',
      notice: json['notice'] ?? 'Welcome to our Family! Stay united ❤️',
      level: json['level'] ?? 1,
      points: json['points'] ?? 0,
      currentExp: json['currentExp'] ?? 0,
      nextLevelExp: json['nextLevelExp'] ?? 5000,
      membersCount: json['membersCount'] ?? 1,
      maxMembersLimit: json['maxMembersLimit'] ?? 100,
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? 'Leader',
      todayRankingPoints: (json['todayRankingPoints'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'banner': banner,
      'description': description,
      'notice': notice,
      'level': level,
      'points': points,
      'currentExp': currentExp,
      'nextLevelExp': nextLevelExp,
      'membersCount': membersCount,
      'maxMembersLimit': maxMembersLimit,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'todayRankingPoints': todayRankingPoints,
    };
  }

  FamilyModel copyWith({
    String? id,
    String? name,
    String? logo,
    String? banner,
    String? description,
    String? notice,
    int? level,
    int? points,
    int? currentExp,
    int? nextLevelExp,
    int? membersCount,
    int? maxMembersLimit,
    String? ownerId,
    String? ownerName,
    double? todayRankingPoints,
  }) {
    return FamilyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      banner: banner ?? this.banner,
      description: description ?? this.description,
      notice: notice ?? this.notice,
      level: level ?? this.level,
      points: points ?? this.points,
      currentExp: currentExp ?? this.currentExp,
      nextLevelExp: nextLevelExp ?? this.nextLevelExp,
      membersCount: membersCount ?? this.membersCount,
      maxMembersLimit: maxMembersLimit ?? this.maxMembersLimit,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      todayRankingPoints: todayRankingPoints ?? this.todayRankingPoints,
    );
  }
}
