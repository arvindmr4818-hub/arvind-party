class FamilyLevelModel {
  final int level;
  final int requiredExp;
  final int maxMembersAllowed;
  final String badgeColorHex;
  final List<String> unlockedPrivileges;

  const FamilyLevelModel({
    required this.level,
    required this.requiredExp,
    required this.maxMembersAllowed,
    required this.badgeColorHex,
    required this.unlockedPrivileges,
  });

  factory FamilyLevelModel.fromJson(Map<String, dynamic> json) {
    return FamilyLevelModel(
      level: json['level'] ?? 1,
      requiredExp: json['requiredExp'] ?? 5000,
      maxMembersAllowed: json['maxMembersAllowed'] ?? 100,
      badgeColorHex: json['badgeColorHex'] ?? '#FF8906',
      unlockedPrivileges: List<String>.from(json['unlockedPrivileges'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'requiredExp': requiredExp,
      'maxMembersAllowed': maxMembersAllowed,
      'badgeColorHex': badgeColorHex,
      'unlockedPrivileges': unlockedPrivileges,
    };
  }
}
