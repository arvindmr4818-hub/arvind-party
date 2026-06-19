import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../core/services/api_service.dart';

class RoomSettingsController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // Loading
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
  // UI SE CALL HONE WALE FUNCTIONS
  // ══════════════════════════════════════════════════════════════

  // room_info_card.dart ke liye
  void updateRoomName(String name) {
    roomName.value = name;
  }

  void updateBanner(String path) {
    roomBanner.value = path;
  }

  void updateTopic(String topic) {
    roomTopic.value = topic;
  }

  // room_seat_card.dart ke liye
  void updateSeatCount(int count) {
    seatCount.value = count;
  }

  // room_security_card.dart ke liye
  void togglePrivacy(bool value) {
    isPrivate.value = value;
  }

  void togglePasswordProtection(bool value) {
    hasPassword.value = value;
  }

  /// Update welcome message
  void updateWelcomeMessage(String message) {
    welcomeMessage.value = message;
  }

  /// Update room announcement
  void updateAnnouncement(String announcement) {
    roomAnnouncement.value = announcement;
  }

  /// Update room password
  void updatePassword(String password) {
    roomPassword.value = password;
  }

  // ══════════════════════════════════════════════════════════════
  // LOAD SETTINGS (Real API)
  // ══════════════════════════════════════════════════════════════
  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final response = await _apiService.get('/room/settings');
      if (response is Map && response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        settings.assignAll(data);

        // Map response to reactive state
        roomName.value = data['roomName']?.toString() ?? '';
        roomTopic.value = data['roomTopic']?.toString() ?? '';
        roomBanner.value = data['roomBanner']?.toString() ?? '';
        roomAnnouncement.value = data['roomAnnouncement']?.toString() ?? '';
        seatCount.value = data['seatCount'] is int
            ? data['seatCount']
            : int.tryParse(data['seatCount']?.toString() ?? '0') ?? 0;
        welcomeMessage.value = data['welcomeMessage']?.toString() ?? '';
        isPrivate.value = data['isPrivate'] == true;
        hasPassword.value = data['hasPassword'] == true;
        roomPassword.value = data['roomPassword']?.toString() ?? '';
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SAVE ALL (Real API)
  // ══════════════════════════════════════════════════════════════
  Future<bool> saveRoomConfigurations() async {
    isLoading.value = true;
    try {
      final payload = {
        'roomName': roomName.value,
        'roomTopic': roomTopic.value,
        'roomBanner': roomBanner.value,
        'roomAnnouncement': roomAnnouncement.value,
        'seatCount': seatCount.value,
        'welcomeMessage': welcomeMessage.value,
        'isPrivate': isPrivate.value,
        'hasPassword': hasPassword.value,
        'roomPassword': roomPassword.value,
      };

      final response = await _apiService.post('/room/settings', body: payload);
      if (response is Map && response['success'] == true) {
        Get.snackbar(
          'Success',
          'Room settings saved successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to save room settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error saving settings: $e');
      Get.snackbar(
        'Error',
        'Failed to save room settings: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
