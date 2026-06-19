import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/private_message_controller.dart';

class PrivateMessageListScreen extends StatelessWidget {
  const PrivateMessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PrivateMessageController>(
      init: PrivateMessageController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Messages'),
            elevation: 0,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.privateChats.isEmpty) {
              return const Center(
                child: Text('No chats yet'),
              );
            }

            return ListView.builder(
              itemCount: controller.privateChats.length,
              itemBuilder: (context, index) {
                final chat = controller.privateChats[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: chat.avatar != null
                        ? NetworkImage(chat.avatar!)
                        : null,
                    child: chat.avatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(chat.username),
                  subtitle: Text(
                    chat.unreadCount > 0
                        ? '${chat.unreadCount} unread messages'
                        : 'No new messages',
                  ),
                  trailing: chat.unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chat.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        )
                      : null,
                  onTap: () => Get.toNamed(
                    '/private-chat',
                    arguments: chat,
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}