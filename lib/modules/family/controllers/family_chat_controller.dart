import 'package:get/get.dart';

class FamilyChatMessage {
  final String senderName;
  final String messageText;
  final String timestamp;
  final bool isMe;

  const FamilyChatMessage(
      {required this.senderName,
      required this.messageText,
      required this.timestamp,
      this.isMe = false});
}

class FamilyChatController extends GetxController {
  final familyMessages = <FamilyChatMessage>[].obs;
  final isMuted = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistoricalChatLogs();
  }

  void _loadHistoricalChatLogs() {
    familyMessages.assignAll([
      const FamilyChatMessage(
          senderName: "Rohan Alpha",
          messageText: "Bhai kal event me sab time par aa jana?",
          timestamp: "09:30 PM"),
      const FamilyChatMessage(
          senderName: "Arvind Kumar",
          messageText: "Haan sab systems setup ready hain, full active raho.",
          timestamp: "09:32 PM",
          isMe: true),
    ]);
  }

  void transmitTextMessage(String text) {
    if (text.trim().isEmpty) return;

    // Real-time integration loop point (Socket.io dispatch stream)
    familyMessages.add(FamilyChatMessage(
      senderName: "Arvind Kumar (You)",
      messageText: text,
      timestamp: "Just Now",
      isMe: true,
    ));
  }
}
