import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/user_center_models.dart';

class UserCenterController extends GetxController {
  final isLoading = false.obs;

  final levelInfo = Rxn<UserLevelInfo>();
  final badges = <AppBadge>[].obs;
  final frames = <AvatarFrame>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserCenterData();
  }

  Future<void> _loadUserCenterData() async {
    isLoading.value = true;

    // TODO: Real Backend API Call (e.g., apiService.getUserCenterInfo())
    await Future.delayed(const Duration(milliseconds: 1000));

    levelInfo.value =
        UserLevelInfo(currentLevel: 14, currentExp: 8500, nextLevelExp: 10000);

    badges.assignAll([
      AppBadge(
          id: 'b1',
          name: 'Top Gifter',
          description: 'Gifted over 10k diamonds',
          iconPath: '💎',
          isUnlocked: true),
      AppBadge(
          id: 'b2',
          name: 'Social Butterfly',
          description: 'Followed 100 people',
          iconPath: '🦋',
          isUnlocked: true),
      AppBadge(
          id: 'b3',
          name: 'Room Star',
          description: 'Reach 10k room audience',
          iconPath: '⭐',
          isUnlocked: false),
      AppBadge(
          id: 'b4',
          name: 'VIP',
          description: 'Subscribed to VIP',
          iconPath: '👑',
          isUnlocked: false),
    ]);

    frames.assignAll([
      AvatarFrame(
          id: 'f1',
          name: 'Default Ring',
          imagePath: 'ring',
          isUnlocked: true,
          isEquipped: true),
      AvatarFrame(
          id: 'f2', name: 'Golden Wings', imagePath: 'wings', isUnlocked: true),
      AvatarFrame(
          id: 'f3',
          name: 'Dragon Fire',
          imagePath: 'dragon',
          isUnlocked: false),
      AvatarFrame(
          id: 'f4', name: 'Neon Vibes', imagePath: 'neon', isUnlocked: false),
    ]);

    isLoading.value = false;
  }

  void equipFrame(String frameId) {
    final frame = frames.firstWhereOrNull((f) => f.id == frameId);
    if (frame == null) return;

    // Backend call to save equipped frame goes here...

    final updatedList =
        frames.map((f) => f.copyWith(isEquipped: f.id == frameId)).toList();
    frames.assignAll(updatedList);
    Get.snackbar('Equipped', '${frame.name} frame equipped successfully!',
        backgroundColor: Colors.green, colorText: Colors.white);
  }
}
