// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/controllers/chat_controller.dart
// ARVIND PARTY - CHAT CONTROLLER (Full Logic: Send, Reply, React, Pin, Delete)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_model.dart';
import '../repositories/chat_repository.dart';

class ChatController extends GetxController {
  final ChatRepository _repo = ChatRepository();

  // Observables
  final messages = <MessageModel>[].obs;
  final chatInfo = Rxn<ChatModel>();
  final currentChatId = ''.obs;
  final TextEditingController textController = TextEditingController();
  final replyToMessage = Rxn<MessageModel>();
  final isTyping = false.obs;
  final isLoading = false.obs;

  StreamSubscription? _messageSub;

  @override
  void onClose() {
    _messageSub?.cancel();
    _repo.disconnectSocket();
    textController.dispose();
    super.onClose();
  }

  // --- INIT & LOAD ---
  Future<void> initChat(String chatId) async {
    currentChatId.value = chatId;
    isLoading.value = true;
    try {
      chatInfo.value = await _repo.getChatInfo(chatId);
      messages.assignAll(await _repo.getMessages(chatId));
      _repo.connectSocket(chatId, 'currentUserId');
      _listenSocket();
    } finally { isLoading.value = false; }
  }

  void _listenSocket() {
    _messageSub = _repo.messageStream.listen((msg) {
      final index = messages.indexWhere((m) => m.id == msg.id);
      if (index != -1) {
        messages[index] = msg;
        messages.refresh();
      } else {
        messages.add(msg);
      }
    });
  }

  // --- SEND MESSAGE ---
  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final Map<String, dynamic> payload = {
      'chatId': currentChatId.value,
      'senderId': 'currentUserId',
      'senderName': 'You',
      'type': 'text',
      'text': text,
      'repliedToMessageId': replyToMessage.value?.id,
      'mentionedUserIds': _extractMentions(text),
    };
    _repo.emitSendMessage(payload);
    textController.clear();
    replyToMessage.value = null;
  }

  List<String> _extractMentions(String text) {
    final regex = RegExp(r'@(\w+)');
    return regex.allMatches(text).map((m) => m.group(1)!).toList();
  }

  void sendSticker(String stickerUrl) {
    final payload = {
      'chatId': currentChatId.value,
      'senderId': 'currentUserId',
      'senderName': 'You',
      'type': 'sticker',
      'stickerUrl': stickerUrl,
    };
    _repo.emitSendMessage(payload);
  }

  // --- REACTIONS ---
  void toggleReaction(String messageId, String emoji) {
    _repo.emitReaction(messageId, emoji, 'currentUserId');
  }

  // --- DELETE & PIN ---
  void deleteMessage(String messageId) => _repo.emitDeleteMessage(messageId);
  void pinMessage(String messageId, {bool pin = true}) => _repo.emitPinMessage(messageId, pin);

  // --- REPLY ---
  void setReply(MessageModel message) => replyToMessage.value = message;
  void clearReply() => replyToMessage.value = null;
}