class TaskModel {
  final String id;
  final String title;
  final String description;
  final int rewardCoins;
  final int progress;
  final int target;
  final bool isClaimed;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.rewardCoins,
    required this.progress,
    required this.target,
    this.isClaimed = false,
  });

  bool get isCompleted => progress >= target;

  TaskModel copyWith({bool? isClaimed, int? progress}) => TaskModel(
      id: id,
      title: title,
      description: description,
      rewardCoins: rewardCoins,
      progress: progress ?? this.progress,
      target: target,
      isClaimed: isClaimed ?? this.isClaimed);
}
