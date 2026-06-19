// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/repositories/chat_repository.dart
// ARVIND PARTY - CHAT REPOSITORY (API + Socket + Mock)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/constants/env_config.dart';
import '../models/chat_model.dart';

class ChatRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));
  IO.Socket? _socket;
  StreamController<MessageModel>? _messageStream;

  // --- REST API ---
  Future<List<MessageModel>> getMessages(String chatId, {int page = 1}) async {
    try {
      final response = await _dio.get('/chats/$chatId/messages', queryParameters: {'page': page});
      return (response.data['data'] as List)
          .map((e) => MessageModel.fromJson(e))
          .toList();
    } catch (e) { return _mockMessages(chatId); }
  }

  Future<ChatModel> getChatInfo(String chatId) async {
    final response = await _dio.get('/chats/$chatId');
    return ChatModel.fromJson(response.data['data']);
  }

  // --- SOCKET.IO (Real-time Chat) ---
  void connectSocket(String chatId, String userId) {
    _socket = IO.io(EnvConfig.socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    _socket!.connect();
    _socket!.emit('join_chat', {'chatId': chatId, 'userId': userId});
    
    _messageStream = StreamController<MessageModel>.broadcast();
    _socket!.on('new_message', (data) {
      _messageStream!.add(MessageModel.fromJson(data));
    });
    _socket!.on('message_deleted', (data) => _messageStream!.add(MessageModel.fromJson(data)));
    _socket!.on('message_pinned', (data) => _messageStream!.add(MessageModel.fromJson(data)));
    _socket!.on('message_reacted', (data) => _messageStream!.add(MessageModel.fromJson(data)));
  }

  Stream<MessageModel> get messageStream => _messageStream!.stream;
  
  void emitSendMessage(Map<String, dynamic> data) => _socket?.emit('send_message', data);
  void emitDeleteMessage(String messageId) => _socket?.emit('delete_message', {'messageId': messageId});
  void emitPinMessage(String messageId, bool pin) => _socket?.emit('pin_message', {'messageId': messageId, 'pin': pin});
  void emitReaction(String messageId, String emoji, String userId) => 
      _socket?.emit('react_message', {'messageId': messageId, 'emoji': emoji, 'userId': userId});
  void disconnectSocket() => _socket?.disconnect();

  // --- MOCK DATA ---
  List<MessageModel> _mockMessages(String chatId) {
    return List.generate(20, (index) => MessageModel(
      id: 'msg_$index', chatId: chatId, senderId: 'u${index % 3}',
      senderName: 'User ${index % 3}', type: MessageType.text,
      text: 'Mock message number $index', createdAt: DateTime.now().subtract(Duration(minutes: 20 - index)),
    ));
  }
}