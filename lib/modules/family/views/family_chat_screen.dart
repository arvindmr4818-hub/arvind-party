import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_chat_controller.dart';

class FamilyChatScreen extends StatefulWidget {
  const FamilyChatScreen({super.key});

  @override
  State<FamilyChatScreen> createState() => _FamilyChatScreenState();
}

class _FamilyChatScreenState extends State<FamilyChatScreen> {
  final FamilyChatController controller = Get.put(FamilyChatController());
  final TextEditingController _msgInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgInputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_msgInputController.text.trim().isNotEmpty) {
      controller.transmitTextMessage(_msgInputController.text);
      _msgInputController.clear();

      // Auto scroll animation downstream logic anchor
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Family Official Chat",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15)),
            Text("Active encrypted data stream channel",
                style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
          ],
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                // 1. Core Messaging Render Feed Scroll Area
                Expanded(
                  child: Obx(() => ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(14),
                        itemCount: controller.familyMessages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.familyMessages[index];
                          return _buildChatBubble(msg);
                        },
                      )),
                ),

                // 2. Interactive Input Action Bar Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xff15141F),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _msgInputController,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: "Type internal message...",
                            hintStyle: const TextStyle(
                                color: Colors.white24, fontSize: 13),
                            filled: true,
                            fillColor: const Color(0xff0F0E17),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none),
                          ),
                          onFieldSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded,
                            color: Color(0xffFF8906), size: 22),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(FamilyChatMessage msg) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMe ? const Color(0xffFF8906) : const Color(0xff1A1924),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: msg.isMe ? const Radius.circular(12) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : const Radius.circular(12),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 260),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!msg.isMe)
              Text(msg.senderName,
                  style: const TextStyle(
                      color: Colors.cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            if (!msg.isMe) const SizedBox(height: 4),
            Text(msg.messageText,
                style: TextStyle(
                    color: msg.isMe ? Colors.black : Colors.white,
                    fontSize: 13)),
            const SizedBox(height: 2),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(msg.timestamp,
                  style: TextStyle(
                      color: msg.isMe ? Colors.black38 : Colors.white24,
                      fontSize: 8)),
            ),
          ],
        ),
      ),
    );
  }
}
