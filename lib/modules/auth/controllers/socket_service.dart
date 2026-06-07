// lib/modules/auth/controllers/socket_service.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as io_socket;
import '../../../core/constants/api_constants.dart';
import '../../../core/services/api_service.dart';

class SocketService extends GetxService {
  io_socket.Socket? socket;
  final GetStorage _storage = GetStorage();

  final isConnected = false.obs;
  final unreadNotifications = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  void _init() {
    try {
      final token = _storage.read('auth_token');
      socket = io_socket.io(
        ApiConstants.baseUrl,
        io_socket.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );
      if (token != null) {
        socket!.io.options?['extraHeaders'] = {'Authorization': 'Bearer $token'};
      }
      socket!.onConnect((_) => isConnected.value = true);
      socket!.onDisconnect((_) => isConnected.value = false);
      socket!.connect();
    } catch (_) {
      isConnected.value = false;
    }
  }

  void emit(String event, dynamic data) {
    if (socket != null && isConnected.value) {
      socket!.emit(event, data);
    }
  }

  void on(String event, Function(dynamic) handler) {
    socket?.on(event, handler);
  }

  @override
  void onClose() {
    socket?.dispose();
    super.onClose();
  }
}
