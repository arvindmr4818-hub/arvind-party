import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart' as msg;
import '../widgets/chat_input_bar.dart';

class RoomChatScreen extends GetView<ChatController> {
  final String roomId;
  final String roomName;
  const RoomChatScreen({super.key, required this.roomId, required this.roomName});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    controller.initChat(roomId);
    return Scaffold(
      appBar: AppBar(title: Text(roomName), actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})]),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return Column(children: [
          Expanded(child: ListView.builder(reverse: true, itemCount: controller.messages.length, itemBuilder: (context, index) {
            final message = controller.messages[controller.messages.length - 1 - index];
            return msg.MessageBubble(message: message, isMe: message.senderId == 'currentUserId');
          })),
          const ChatInputBar(),
        ]);
      }),
    );
  }
}