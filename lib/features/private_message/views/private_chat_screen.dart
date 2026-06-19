import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/private_message_controller.dart';
import '../models/private_message_model.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/file_picker_widget.dart';

class PrivateChatScreen extends StatefulWidget {
  final PrivateChatUser chatUser;

  const PrivateChatScreen({required this.chatUser, super.key});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  late PrivateMessageController messageController;
  late UserStatusController statusController;
  final messageTextController = TextEditingController();
  bool showFileOptions = false;

  @override
  void initState() {
    super.initState();
    messageController = Get.find<PrivateMessageController>();
    statusController = Get.find<UserStatusController>();
    messageController.fetchMessages(widget.chatUser.userId);
    statusController.fetchUserStatus(widget.chatUser.userId);
  }

  @override
  void dispose() {
    messageTextController.dispose();
    messageController.setTypingStatus(widget.chatUser.userId, false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.chatUser.username),
            Obx(() {
              final status = statusController.userStatus.value;
              if (status == null) {
                return const Text(
                  'Loading...',
                  style: TextStyle(fontSize: 12),
                );
              }
              return Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: status.isOnline ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status.getStatusText(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (messageController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                reverse: true,
                itemCount: messageController.messages.length +
                    (messageController.recipientTypingStatus.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == 0 &&
                      messageController.recipientTypingStatus.value) {
                    return TypingIndicator(
                      userName: widget.chatUser.username,
                    );
                  }

                  final msgIndex = messageController.recipientTypingStatus.value
                      ? index - 1
                      : index;
                  final message = messageController.messages[
                      messageController.messages.length - 1 - msgIndex];

                  return MessageBubble(
                    message: message,
                    isCurrentUser: message.senderId == 'current_user_id',
                    onEdit: () => _editMessage(message),
                    onDelete: () =>
                        messageController.deleteMessage(message.id),
                  );
                },
              );
            }),
          ),

          if (showFileOptions)
            FilePickerWidget(onFilePicked: (filePath) {
              // Handle file pick
            }),

          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => showFileOptions = !showFileOptions);
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageTextController,
                          decoration: InputDecoration(
                            hintText: 'Message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isEmpty) {
                              messageController.setTypingStatus(
                                widget.chatUser.userId,
                                false,
                              );
                            } else {
                              messageController.setTypingStatus(
                                widget.chatUser.userId,
                                true,
                              );
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (messageTextController.text.isNotEmpty) {
                            messageController.sendMessage(
                              recipientId: widget.chatUser.userId,
                              content: messageTextController.text,
                            );
                            messageTextController.clear();
                            messageController.setTypingStatus(
                              widget.chatUser.userId,
                              false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editMessage(PrivateMessage message) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              messageController.editMessage(
                messageId: message.id,
                newContent: controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}