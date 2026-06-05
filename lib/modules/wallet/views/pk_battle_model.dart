class PkBattleModel {
  final String battleId;
  final String host1Id;
  final String host1Name;
  final String host1Avatar;
  final String host2Id;
  final String host2Name;
  final String host2Avatar;
  final int host1Score;
  final int host2Score;
  final int remainingSeconds;
  final bool isActive;

  PkBattleModel({
    required this.battleId,
    required this.host1Id,
    required this.host1Name,
    required this.host1Avatar,
    required this.host2Id,
    required this.host2Name,
    required this.host2Avatar,
    this.host1Score = 0,
    this.host2Score = 0,
    this.remainingSeconds = 300, // 5 minutes default
    this.isActive = true,
  });

  PkBattleModel copyWith({
    int? host1Score,
    int? host2Score,
    int? remainingSeconds,
    bool? isActive,
  }) {
    return PkBattleModel(
      battleId: battleId,
      host1Id: host1Id,
      host1Name: host1Name,
      host1Avatar: host1Avatar,
      host2Id: host2Id,
      host2Name: host2Name,
      host2Avatar: host2Avatar,
      host1Score: host1Score ?? this.host1Score,
      host2Score: host2Score ?? this.host2Score,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isActive: isActive ?? this.isActive,
    );
  }
}
