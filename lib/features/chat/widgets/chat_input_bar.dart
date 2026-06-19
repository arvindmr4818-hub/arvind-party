import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'reaction_picker.dart';

class ChatInputBar extends GetView<ChatController> {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          if (controller.replyToMessage.value == null) return const SizedBox();
          return Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Icon(Icons.reply, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.replyToMessage.value!.text ?? 'Replying to sticker',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: controller.clearReply,
                ),
              ],
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.emoji_emotions, color: Colors.orange),
                onPressed: () => _showEmojiPicker(context),
              ),
              IconButton(
                icon: const Icon(Icons.sticky_note_2, color: Colors.purple),
                onPressed: () => _showStickerPicker(context),
              ),
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: controller.sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ReactionPicker(
        onReactionSelected: (emoji) {
          controller.textController.text += emoji;
          Navigator.pop(ctx);
        },
        isEmojiPicker: true,
      ),
    );
  }

  void _showStickerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemCount: 20,
          itemBuilder: (_, index) {
            final url = 'https://picsum.photos/seed/${100 + index}/150';
            return GestureDetector(
              onTap: () {
                controller.sendSticker(url);
                Navigator.pop(ctx);
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.network(url, fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }
}