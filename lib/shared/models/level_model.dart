// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/shared/models/level_model.dart
// ═══════════════════════════════════════════════════════════════════════════

class UserLevelModel {
  final int wealthLevel;
  final int wealthExp;
  final int charmLevel;
  final int charmExp;
  final int familyLevel;

  UserLevelModel({
    required this.wealthLevel,
    required this.wealthExp,
    required this.charmLevel,
    required this.charmExp,
    required this.familyLevel,
  });

  factory UserLevelModel.empty() {
    return UserLevelModel(
      wealthLevel: 1,
      wealthExp: 0,
      charmLevel: 1,
      charmExp: 0,
      familyLevel: 0,
    );
  }

  factory UserLevelModel.fromJson(Map<String, dynamic> json) {
    return UserLevelModel(
      wealthLevel: json['wealthLevel'] ?? 1,
      wealthExp: json['wealthExp'] ?? 0,
      charmLevel: json['charmLevel'] ?? 1,
      charmExp: json['charmExp'] ?? 0,
      familyLevel: json['familyLevel'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wealthLevel': wealthLevel,
      'wealthExp': wealthExp,
      'charmLevel': charmLevel,
      'charmExp': charmExp,
      'familyLevel': familyLevel,
    };
  }
}
