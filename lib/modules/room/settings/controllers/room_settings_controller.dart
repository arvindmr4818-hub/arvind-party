import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class RoomSettingsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // ── Loading ────────────────────────────────────────────────────
  var isLoading = false.obs;
  var settings = <String, dynamic>{}.obs;

  // ── Room Info ──────────────────────────────────────────────────
  var roomName = ''.obs;
  var roomTopic = ''.obs;
  var roomBanner = ''.obs;

  // ── Announcement ───────────────────────────────────────────────
  var roomAnnouncement = ''.obs;

  // ── Seats ──────────────────────────────────────────────────────
  var seatCount = 0.obs;

  // ── Welcome ────────────────────────────────────────────────────
  var welcomeMessage = ''.obs;

  // ── Security ───────────────────────────────────────────────────
  var isPrivate = false.obs;
  var hasPassword = false.obs;
  var roomPassword = ''.obs;

  // ══════════════════════════════════════════════════════════════
  // UI SE CALL HONE WALE FUNCTIONS (MISSING ERRORS FIX)
  // ══════════════════════════════════════════════════════════════

  // room_info_card.dart ke errors ke liye
  void updateRoomName(String name) {
    roomName.value = name;
  }

  void updateBanner(String path) {
    roomBanner.value = path;
  }

  // ✅ JOD DIYA: Isse RoomInfoCard ka updateTopic wala error jad se khatam ho jayega
  void updateTopic(String topic) {
    roomTopic.value = topic;
  }

  // room_seat_card.dart ke error ke liye
  void updateSeatCount(int count) {
    seatCount.value = count;
  }

  // room_security_card.dart ke errors ke liye
  void togglePrivacy(bool value) {
    isPrivate.value = value;
  }

  void togglePasswordProtection(bool value) {
    hasPassword.value = value;
  }

  // ══════════════════════════════════════════════════════════════
  // LOAD
  // ══════════════════════════════════════════════════════════════
  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      // TODO: replace with real API call
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SAVE ALL
  // ══════════════════════════════════════════════════════════════
  Future<void> saveRoomConfigurations() async {
    isLoading.value = true;
    try {
      // TODO: await _apiService.saveRoomSettings({...});
    } catch (e) {
      debugPrint('Error saving settings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}