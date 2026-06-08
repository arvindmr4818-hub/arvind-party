import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class MissionController extends GetxController {
  final dailyTasks = <TaskModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
  }

  void _loadTasks() {
    dailyTasks.assignAll([
      TaskModel(
          id: 't1',
          title: 'Daily Login',
          description: 'Log in to the app once a day.',
          rewardCoins: 10,
          progress: 1,
          target: 1),
      TaskModel(
          id: 't2',
          title: 'Stay in a Room',
          description: 'Watch a live stream for 10 minutes.',
          rewardCoins: 30,
          progress: 4,
          target: 10),
      TaskModel(
          id: 't3',
          title: 'Send Gifts',
          description: 'Send any 3 gifts in live rooms.',
          rewardCoins: 50,
          progress: 3,
          target: 3,
          isClaimed: true),
    ]);
  }

  void claimReward(String taskId) {
    final index = dailyTasks.indexWhere((t) => t.id == taskId);
    if (index != -1 &&
        dailyTasks[index].isCompleted &&
        !dailyTasks[index].isClaimed) {
      // TODO: API Call apiService.claimMission(taskId)
      dailyTasks[index] = dailyTasks[index].copyWith(isClaimed: true);
      Get.snackbar('Reward Claimed!',
          '+${dailyTasks[index].rewardCoins} Coins added to your wallet',
          backgroundColor: Colors.green, colorText: Colors.white);
    }
  }
}
