class AgencyTargetModel {
  final String targetId;
  final String targetTitle; // e.g., "Elite Star Anchor Threshold"
  final int requiredCoins;
  final double requiredHours;
  final int rewardBonusUSD;
  final String specialPrivilegeUnlock;

  const AgencyTargetModel({
    required this.targetId,
    required this.targetTitle,
    required this.requiredCoins,
    required this.requiredHours,
    required this.rewardBonusUSD,
    required this.specialPrivilegeUnlock,
  });

  factory AgencyTargetModel.fromJson(Map<String, dynamic> json) {
    return AgencyTargetModel(
      targetId: json['targetId'] ?? '',
      targetTitle: json['targetTitle'] ?? '',
      requiredCoins: json['requiredCoins'] ?? 0,
      requiredHours: (json['requiredHours'] ?? 0.0).toDouble(),
      rewardBonusUSD: json['rewardBonusUSD'] ?? 0,
      specialPrivilegeUnlock: json['specialPrivilegeUnlock'] ?? 'None',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'targetTitle': targetTitle,
      'requiredCoins': requiredCoins,
      'requiredHours': requiredHours,
      'rewardBonusUSD': rewardBonusUSD,
      'specialPrivilegeUnlock': specialPrivilegeUnlock,
    };
  }
}
