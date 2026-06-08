class MissionModel {
  final String id;
  final String title;
  final String description;
  final int target;
  final int currentProgress;
  final int rewardCoins;
  final bool isCompleted;
  final bool isClaimed;

  MissionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.target,
    required this.currentProgress,
    required this.rewardCoins,
    required this.isCompleted,
    required this.isClaimed,
  });

  factory MissionModel.fromJson(Map<String, dynamic> json) {
    return MissionModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      target: json['target'] ?? 1,
      currentProgress: json['currentProgress'] ?? 0,
      rewardCoins: json['rewardCoins'] ?? 0,
      isCompleted: json['isCompleted'] ?? false,
      isClaimed: json['isClaimed'] ?? false,
    );
  }
}