// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/controllers/create_room_controller.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/room_model.dart';
import 'room_controller.dart';
import '../../../routes/app_routes.dart';

class CreateRoomController extends GetxController {
  // ─── FORM STATE ──────────────────────────────────────────────────────────
  final roomName = ''.obs;
  final roomTopic = ''.obs;
  final welcomeMessage = ''.obs;
  final announcement = ''.obs;
  final roomType = 'public'.obs; // public / private / password
  final password = ''.obs;
  final bannerUrl = ''.obs;
  final seatCount = 8.obs; // 8 / 10 / 15 / 20 / 25
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // ─── SEAT OPTIONS ────────────────────────────────────────────────────────
  final seatOptions = const [8, 10, 15, 20, 25];

  // ─── PASSWORD VISIBILITY ─────────────────────────────────────────────────
  void togglePasswordVisibility() => isPasswordVisible.toggle();

  // ─── ROOM TYPE ───────────────────────────────────────────────────────────
  void selectRoomType(String type) {
    roomType.value = type;
    if (type != 'password') password.value = '';
  }

  // ─── VALIDATION ──────────────────────────────────────────────────────────
  bool _validate() {
    if (roomName.value.trim().isEmpty) {
      _snack('Room name required', 'Please enter a name for your room.');
      return false;
    }
    if (roomName.value.trim().length < 3) {
      _snack('Too short', 'Room name must be at least 3 characters.');
      return false;
    }
    if (roomType.value == 'password' && password.value.trim().length < 4) {
      _snack('Password too short', 'Password must be at least 4 characters.');
      return false;
    }
    return true;
  }

  // ─── LAUNCH ROOM ─────────────────────────────────────────────────────────
  Future<void> launchRoom() async {
    if (!_validate()) return;

    try {
      isLoading.value = true;

      final newRoom = RoomModel(
        id: 'room_${DateTime.now().millisecondsSinceEpoch}',
        title: roomName.value.trim(),
        topic: roomTopic.value.trim().isEmpty
            ? 'Welcome to my room!'
            : roomTopic.value.trim(),
        banner: bannerUrl.value.isNotEmpty
            ? bannerUrl.value
            : 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80',
        welcomeMessage: welcomeMessage.value.trim().isEmpty
            ? 'Welcome! Please be respectful 🙏'
            : welcomeMessage.value.trim(),
        announcement: announcement.value.trim(),
        roomType: roomType.value,
        password: roomType.value == 'password' ? password.value.trim() : null,
        seatCount: seatCount.value,
        onlineUsers: 1,
        hostId: 'me', // TODO: real userId from session
      );

      // TODO: API call — await ApiService.post('/rooms/create', newRoom.toJson())

      await Future.delayed(const Duration(milliseconds: 800)); // mock delay

      isLoading.value = false;

      // RoomController mein room set karo aur room screen par jao
      final roomCtrl = Get.find<RoomController>();
      roomCtrl.initRoom(newRoom, asOwner: true);

      Get.offNamed(AppRoutes.voiceRoom);
    } catch (e) {
      isLoading.value = false;
      _snack('Error', 'Failed to create room. Try again.');
    }
  }

  void _snack(String title, String msg) {
    Get.snackbar(title, msg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF15141F),
        colorText: const Color(0xFFFFFFFF),
        borderRadius: 12,
        margin: const EdgeInsets.all(12));
  }
}
