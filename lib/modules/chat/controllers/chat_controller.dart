// lib/modules/chat/controllers/chat_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_socket;
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      senderId: (json['senderId'] ?? '').toString(),
      receiverId: (json['receiverId'] ?? '').toString(),
      content: (json['content'] ?? json['text'] ?? '').toString(),
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : (json['timestamp'] != null ? DateTime.tryParse(json['timestamp'].toString()) : null),
    );
  }

  bool get isMine => senderId == (GetStorage().read('user_id') ?? '').toString();
  String get text => content;
}

class ChatController extends GetxController {
  io_socket.Socket? socket;
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  var isConnected = false.obs;
  var messages = <ChatMessage>[].obs;
  final messageInputController = TextEditingController();

  String get currentUserId => (_storage.read('user_id') ?? '').toString();
  var targetUserId = ''.obs;
  var isLoadingHistory = false.obs;
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initChatSocket();
  }

  @override
  void onClose() {
    socket?.dispose();
    messageInputController.dispose();
    super.onClose();
  }

  void _initChatSocket() {
    if (currentUserId.isEmpty) return;
    try {
      socket = io_socket.io(
        ApiConstants.baseUrl,
        io_socket.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );

      socket!.connect();

      socket!.onConnect((_) {
        isConnected.value = true;
        socket!.emit('register_user', {'userId': currentUserId});
      });

      socket!.on('receive_private_message', (data) {
        if (data is Map) {
          final newMessage = ChatMessage.fromJson(Map<String, dynamic>.from(data));
          if (newMessage.senderId == targetUserId.value) {
            messages.insert(0, newMessage);
          } else {
            unreadCount.value++;
            Get.snackbar(
              'New Message',
              'You received a private message.',
              backgroundColor: const Color(0xFF15141F),
              colorText: Colors.white,
            );
          }
        }
      });

      socket!.on('message_sent_ack', (data) {
        if (data is Map && data['success'] == true && data['message'] != null) {
          messages.insert(0, ChatMessage.fromJson(Map<String, dynamic>.from(data['message'])));
        }
      });

      socket!.onDisconnect((_) {
        isConnected.value = false;
      });
    } catch (_) {
      isConnected.value = false;
    }
  }

  Future<void> openChat(String targetId) async {
    targetUserId.value = targetId;
    await loadHistory(targetId);
  }

  Future<void> loadHistory(String targetId) async {
    if (currentUserId.isEmpty || targetId.isEmpty) return;
    targetUserId.value = targetId;
    isLoadingHistory.value = true;
    try {
      final response = await _api.get('/chat/history/$currentUserId/$targetId');
      if (response is Map && response['success'] == true) {
        final List<dynamic> data = (response['data'] as List?) ?? [];
        final list = data.map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m))).toList();
        messages.assignAll(list);
      }
    } catch (_) {
      // local fallback
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // Send a private message. Can be called with no args (uses internal input controller)
  // or with explicit text + targetId.
  void sendMessage([String? text, String? targetId]) {
    final messageText = (text ?? messageInputController.text).trim();
    final receiverId = (targetId ?? targetUserId.value).trim();
    if (messageText.isEmpty || receiverId.isEmpty) return;

    if (socket != null && isConnected.value) {
      socket!.emit('send_private_message', {
        'senderId': currentUserId,
        'receiverId': receiverId,
        'content': messageText,
      });
    } else {
      // Offline optimistic add
      final local = ChatMessage(
        id: 'local_${DateTime.now().millisecondsSinceEpoch}',
        senderId: currentUserId,
        receiverId: receiverId,
        content: messageText,
        timestamp: DateTime.now(),
      );
      messages.insert(0, local);
    }
    if (text == null) {
      messageInputController.clear();
    }
  }

  void markAllRead() {
    unreadCount.value = 0;
  }
}
