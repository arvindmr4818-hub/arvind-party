import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../widgets/message_bubble.dart' as msg;
import '../widgets/chat_input_bar.dart';

class PrivateChatScreen extends GetView<ChatController> {
  final String chatId;
  final String otherUserName;
  final String? otherUserAvatar;
  const PrivateChatScreen({super.key, required this.chatId, required this.otherUserName, this.otherUserAvatar});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());
    controller.initChat(chatId);
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(otherUserAvatar ?? 'https://picsum.photos/100')),
          const SizedBox(width: 12), Text(otherUserName),
        ]),
        actions: [IconButton(icon: const Icon(Icons.videocam), onPressed: () {}), IconButton(icon: const Icon(Icons.call), onPressed: () {})],
      ),
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