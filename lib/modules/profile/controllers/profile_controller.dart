// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/profile/controllers/profile_controller.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  // ─── USER DATA ────────────────────────────────────────────────────────────
  final userId = 'ARV-100001'.obs;
  final userName = 'Arvind'.obs;
  final userBio = 'Live & Party Every Night 🎉'.obs;
  final userAvatar = ''.obs;
  final userLevel = 1.obs;
  final userXp = 0.obs;
  final xpToNextLevel = 1000.obs;
  final isVip = false.obs;
  final vipLevel = 0.obs; // 0 = no VIP, 1-5 = VIP tiers
  final gender = 'male'.obs;
  final userCoins = 25000.obs;
  final userDiamonds = 0.obs;

  // ─── STATS ────────────────────────────────────────────────────────────────
  final followers = 0.obs;
  final following = 0.obs;
  final totalGifts = 0.obs;
  final roomsHosted = 0.obs;
  final visitors = 0.obs;

  // ─── BADGES ───────────────────────────────────────────────────────────────
  final badges = <BadgeModel>[].obs;

  // ─── FOLLOW STATE ─────────────────────────────────────────────────────────
  final isFollowing = false.obs; // used when viewing another user's profile

  // ─── STATE ────────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final isEditMode = false.obs;

  final _storage = GetStorage();

  // ─────────────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    _loadDummyData();
  }

  void _loadFromStorage() {
    userName.value = _storage.read<String>('user_name') ?? 'User';
    userAvatar.value = _storage.read<String>('user_avatar') ?? '';
    userCoins.value = _storage.read<int>('user_coins') ?? 25000;
    userLevel.value = _storage.read<int>('user_level') ?? 1;
  }

  void _loadDummyData() {
    followers.value = 1280;
    following.value = 345;
    totalGifts.value = 4820;
    roomsHosted.value = 38;
    visitors.value = 9300;
    userXp.value = 750;
    xpToNextLevel.value = 1000;
    isVip.value = true;
    vipLevel.value = 2;

    badges.assignAll([
      BadgeModel(
          id: 'b1',
          name: 'Top Host',
          icon: '🏆',
          color: const Color(0xFFFFD700)),
      BadgeModel(id: 'b2', name: 'Rich', icon: '💎', color: Colors.cyanAccent),
      BadgeModel(
          id: 'b3',
          name: 'Party King',
          icon: '👑',
          color: const Color(0xFFFF8906)),
      BadgeModel(
          id: 'b4', name: 'Verified', icon: '✅', color: Colors.greenAccent),
    ]);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ACTIONS
  // ─────────────────────────────────────────────────────────────────────────

  double get xpProgress =>
      xpToNextLevel.value > 0 ? userXp.value / xpToNextLevel.value : 0.0;

  void toggleFollow() {
    isFollowing.toggle();
    if (isFollowing.value) {
      followers.value++;
    } else {
      followers.value--;
    }
  }

  void goToWallet() => Get.toNamed(AppRoutes.wallet);
  void goToSettings() {
    Get.snackbar('Settings', 'Coming soon!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF15141F),
        colorText: Colors.white);
  }

  void logout() {
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF15141F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Logout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: const Text('Are you sure you want to logout?',
          style: TextStyle(color: Colors.white60)),
      actions: [
        TextButton(
            onPressed: Get.back,
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () {
            _storage.erase();
            Get.offAllNamed(AppRoutes.login);
          },
          child: const Text('Logout',
              style: TextStyle(
                  color: Colors.redAccent, fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }

  String get vipLabel {
    switch (vipLevel.value) {
      case 1:
        return 'VIP';
      case 2:
        return 'VIP II';
      case 3:
        return 'VIP III';
      case 4:
        return 'VIP IV';
      case 5:
        return 'VIP V';
      default:
        return '';
    }
  }
}

class BadgeModel {
  final String id;
  final String name;
  final String icon;
  final Color color;
  const BadgeModel(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color});
}
