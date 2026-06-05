import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoomSettingsController extends GetxController {
  // 1. Core Info Reactive States
  final roomName = "Music Party".obs;
  final roomTopic = "Welcome Everyone".obs;
  final roomCategory = "Music & Chill".obs;
  final roomLanguage = "Hindi/English".obs;

  // 2. Banner Asset Reference State
  final roomBanner =
      "https://images.unsplash.com/photo-1614680376593-902f74fa0d41?w=500&q=80"
          .obs;

  // 3. Security Config States
  final isPrivate = false.obs;
  final hasPassword = false.obs;
  final roomPassword = "".obs;
  final inviteOnly = false.obs;

  // 4. Seat Constraints
  final seatCount = 12.obs;

  // 5. Broadcast Board Text Signals
  final welcomeMessage =
      "Welcome To Arvind Party 🎉 Please Respect Everyone ❤️".obs;
  final roomAnnouncement =
      "Tonight Special Remix DJ Night starts at 9 PM IST!".obs;

  // 6. Advanced Moderation Toggles (Chat, Mic, Gifts)
  final isChatEnabled = true.obs;
  final isSlowMode = false.obs;
  final isMicOpen = true.obs; // true = Open Mic, false = Request Mic System
  final isGiftsEnabled = true.obs;

  final isLoading = false.obs;

  // --- Configuration Mutator Functions ---
  void updateRoomName(String value) => roomName.value = value;
  void updateTopic(String value) => roomTopic.value = value;
  void updateCategory(String value) => roomCategory.value = value;

  void updateBanner(String path) => roomBanner.value = path;

  void togglePrivacy() {
    isPrivate.toggle();
    if (isPrivate.value) hasPassword.value = false;
  }

  void togglePasswordProtection(bool status) {
    hasPassword.value = status;
    if (!status) roomPassword.value = "";
  }

  void changeSeatCount(int value) => seatCount.value = value;
  void updateWelcome(String value) => welcomeMessage.value = value;
  void updateAnnouncement(String value) => roomAnnouncement.value = value;

  // --- Pipeline Save Trigger Block ---
  Future<void> saveRoomConfigurations() async {
    try {
      isLoading.value = true;

      // Future Node.js payload design map matching layout
      final Map<String, dynamic> updatePayload = {
        "title": roomName.value.trim(),
        "topic": roomTopic.value.trim(),
        "category": roomCategory.value,
        "banner": roomBanner.value,
        "isPrivate": isPrivate.value,
        "hasPassword": hasPassword.value,
        "password": hasPassword.value ? roomPassword.value.trim() : null,
        "seatCount": seatCount.value,
        "welcomeMessage": welcomeMessage.value.trim(),
        "announcement": roomAnnouncement.value.trim(),
        "moderation": {
          "chatEnabled": isChatEnabled.value,
          "slowMode": isSlowMode.value,
          "openMic": isMicOpen.value,
          "giftsEnabled": isGiftsEnabled.value,
        }
      };

      // Mock processing delay representing Redis cache clear / MongoDB updates sync
      await Future.delayed(const Duration(milliseconds: 1200));

      Get.snackbar(
        "Control Center",
        "Room settings updated and synced globally! ⚙️",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xff15141F),
        colorText: const Color(0xffFF8906),
      );
    } catch (e) {
      Get.snackbar("Sync Error", "Failed to distribute configurations: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
