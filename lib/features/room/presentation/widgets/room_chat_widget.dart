// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/widgets/room_chat_widget.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomChatWidget extends StatelessWidget {
  const RoomChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<RoomController>();

    return SizedBox(
      height: 210,
      child: Obx(() {
        if (ctrl.chatMessages.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                ctrl.currentRoom.value?.welcomeMessage ??
                    'Welcome! Say hello 👋',
                style: const TextStyle(color: Colors.white24, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return ListView.builder(
          controller: ctrl.chatScrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          itemCount: ctrl.chatMessages.length,
          itemBuilder: (_, i) {
            final msg = ctrl.chatMessages[i];
            return _ChatBubble(
              senderName: msg.senderName,
              message: msg.message,
              isMe: msg.isMe,
            );
          },
        );
      }),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String senderName;
  final String message;
  final bool isMe;
  const _ChatBubble(
      {required this.senderName, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFFFF8906).withValues(alpha: 0.1)
              : const Color(0xFF15141F),
          borderRadius: BorderRadius.circular(12),
          border: isMe
              ? Border.all(color: const Color(0xFFFF8906).withValues(alpha: 0.2))
              : null,
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$senderName  ',
                style: TextStyle(
                  color: isMe ? const Color(0xFFFF8906) : Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              TextSpan(
                text: message,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
