import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get/get.dart';
import '../constants/api_constants.dart';

// ============================================================
// ARVIND PARTY WEB — Socket.io Service for Real-Time Updates
// ============================================================

class SocketService extends GetxService {
  static SocketService get to => Get.find<SocketService>();

  late io.Socket _socket;
  final isConnected = false.obs;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;

  // Stream controllers for real-time events
  final _roomUpdateController = StreamController<Map<String, dynamic>>.broadcast();
  final _userStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  final _withdrawalController = StreamController<Map<String, dynamic>>.broadcast();
  final _reportController = StreamController<Map<String, dynamic>>.broadcast();
  final _ticketController = StreamController<Map<String, dynamic>>.broadcast();
  final _dashboardController = StreamController<Map<String, dynamic>>.broadcast();
  final _banController = StreamController<Map<String, dynamic>>.broadcast();
  final _chatController = StreamController<Map<String, dynamic>>.broadcast();

  // Exposed streams
  Stream<Map<String, dynamic>> get onRoomUpdate => _roomUpdateController.stream;
  Stream<Map<String, dynamic>> get onUserStatus => _userStatusController.stream;
  Stream<Map<String, dynamic>> get onNotification => _notificationController.stream;
  Stream<Map<String, dynamic>> get onWithdrawal => _withdrawalController.stream;
  Stream<Map<String, dynamic>> get onReport => _reportController.stream;
  Stream<Map<String, dynamic>> get onTicket => _ticketController.stream;
  Stream<Map<String, dynamic>> get onDashboardUpdate => _dashboardController.stream;
  Stream<Map<String, dynamic>> get onBan => _banController.stream;
  Stream<Map<String, dynamic>> get onChatMessage => _chatController.stream;

  @override
  void onInit() {
    super.onInit();
    _connect();
  }

  // =========================================================================
  // CONNECTION
  // =========================================================================

  void _connect() {
    _socket = io.io(
      ApiConstants.socketUrl,
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .setExtraHeaders(
            ApiConstants.adminKey.isNotEmpty
                ? {'x-admin-key': ApiConstants.adminKey}
                : {},
          )
          .disableAutoConnect()
          .build(),
    );

    _socket.onConnect(_onConnect);
    _socket.onDisconnect(_onDisconnect);
    _socket.onConnectError(_onConnectError);
    _socket.onError(_onConnectError);
    _socket.onReconnect(_onReconnect);
    _socket.onReconnectAttempt(_onReconnectAttempt);

    _registerListeners();
    _socket.connect();
  }

  void _onConnect(_) {
    isConnected.value = true;
    _reconnectAttempts = 0;
    debugPrint('[SocketService] Connected to ${ApiConstants.socketUrl}');
  }

  void _onDisconnect(_) {
    isConnected.value = false;
    debugPrint('[SocketService] Disconnected');
  }

  void _onConnectError(dynamic data) {
    isConnected.value = false;
    debugPrint('[SocketService] Connection error: $data');
  }

  void _onReconnect(dynamic data) {
    debugPrint('[SocketService] Reconnected successfully');
  }

  void _onReconnectAttempt(dynamic data) {
    _reconnectAttempts++;
    debugPrint('[SocketService] Reconnect attempt $_reconnectAttempts');
  }

  /// Public reconnect — called by UI when user taps "retry"
  void reconnect() {
    if (!isConnected.value && _reconnectAttempts < _maxReconnectAttempts) {
      debugPrint('[SocketService] Manual reconnect triggered');
      _socket.dispose();
      _connect();
    }
  }

  // =========================================================================
  // EVENT LISTENERS (match backend roomSocket.js + chatSocket.js exactly)
  // =========================================================================

  void _registerListeners() {
    // ─── Admin Dashboard Events (from admin middleware / server) ─────
    _socket.on('connect', _onConnect);
    _socket.on('disconnect', _onDisconnect);
    _socket.on('connect_error', _onConnectError);

    _socket.on('room:created', (data) {
      _roomUpdateController.add({'type': 'created', 'data': data});
    });
    _socket.on('room:updated', (data) {
      _roomUpdateController.add({'type': 'updated', 'data': data});
    });
    _socket.on('room:closed', (data) {
      _roomUpdateController.add({'type': 'closed', 'data': data});
    });

    _socket.on('user:status', (data) {
      _userStatusController.add(data as Map<String, dynamic>);
    });

    _socket.on('admin:notification', (data) {
      _notificationController.add(data as Map<String, dynamic>);
    });

    _socket.on('new_report', (data) {
      _reportController.add(data as Map<String, dynamic>);
    });
    _socket.on('new_withdrawal', (data) {
      _withdrawalController.add(data as Map<String, dynamic>);
    });
    _socket.on('new_ticket', (data) {
      _ticketController.add(data as Map<String, dynamic>);
    });
    _socket.on('dashboard_update', (data) {
      _dashboardController.add(data as Map<String, dynamic>);
    });

    _socket.on('user_banned', (data) {
      _banController.add({'type': 'user_banned', ...data as Map<String, dynamic>});
    });
    _socket.on('announcement', (data) {
      _notificationController.add({'type': 'announcement', ...data as Map<String, dynamic>});
    });
    _socket.on('room_closed', (data) {
      _roomUpdateController.add({'type': 'admin_forced_close', 'data': data});
    });

    // ─── Room Socket Events (roomSocket.js) ──────────────────────────
    _socket.on('user_joined', (data) {
      _roomUpdateController.add({'type': 'user_joined', 'data': data});
    });
    _socket.on('user_left', (data) {
      _roomUpdateController.add({'type': 'user_left', 'data': data});
    });
    _socket.on('user_kicked', (data) {
      _roomUpdateController.add({'type': 'user_kicked', 'data': data});
    });
    _socket.on('user_unkicked', (data) {
      _roomUpdateController.add({'type': 'user_unkicked', 'data': data});
    });
    _socket.on('user_admin_muted', (data) {
      _roomUpdateController.add({'type': 'user_admin_muted', 'data': data});
    });
    _socket.on('user_admin_unmuted', (data) {
      _roomUpdateController.add({'type': 'user_admin_unmuted', 'data': data});
    });
    _socket.on('mic_status_changed', (data) {
      _roomUpdateController.add({'type': 'mic_status_changed', 'data': data});
    });

    // ─── Chat Socket Events (chatSocket.js) ──────────────────────────
    _socket.on('receive_room_message', (data) {
      _chatController.add({'type': 'room_message', 'data': data});
    });
    _socket.on('receive_reaction', (data) {
      _chatController.add({'type': 'reaction', 'data': data});
    });
  }

  // =========================================================================
  // EMITTERS — all event names match backend socket listeners exactly
  // =========================================================================

  /// Admin socket auth
  void authenticate(String token) {
    _safeEmit('admin:auth', {'token': token});
  }

  /// Join a room (matches backend: socket.on('join_room', ...))
  void joinRoom(String roomId, String userId, Map<String, dynamic> userProfile) {
    _safeEmit('join_room', {
      'roomId': roomId,
      'userId': userId,
      'userProfile': userProfile,
    });
  }

  /// Leave a room (matches backend: socket.on('leave_room', ...))
  void leaveRoom(String roomId, String userId, Map<String, dynamic> userProfile) {
    _safeEmit('leave_room', {
      'roomId': roomId,
      'userId': userId,
      'userProfile': userProfile,
    });
  }

  /// Toggle mute (matches backend: socket.on('toggle_mic', ...))
  void toggleMic(String roomId, String userId, bool isMuted) {
    _safeEmit('toggle_mic', {
      'roomId': roomId,
      'userId': userId,
      'isMuted': isMuted,
    });
  }

  /// Kick user from room (matches backend: socket.on('kick_user', ...))
  void kickUser(String roomId, String targetUserId, String adminId) {
    _safeEmit('kick_user', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'adminId': adminId,
    });
  }

  /// Admin mute user (matches backend: socket.on('admin_mute_user', ...))
  void adminMuteUser(String roomId, String targetUserId, String adminId) {
    _safeEmit('admin_mute_user', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'adminId': adminId,
    });
  }

  /// Unkick user (matches backend: socket.on('unkick_user', ...))
  void unkickUser(String roomId, String targetUserId, String adminId) {
    _safeEmit('unkick_user', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'adminId': adminId,
    });
  }

  /// Admin unmute user (matches backend: socket.on('admin_unmute_user', ...))
  void adminUnmuteUser(String roomId, String targetUserId, String adminId) {
    _safeEmit('admin_unmute_user', {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'adminId': adminId,
    });
  }

  /// Send room text message (matches backend: socket.on('send_room_message', ...))
  void sendRoomMessage(String roomId, String senderId, String message) {
    _safeEmit('send_room_message', {
      'roomId': roomId,
      'senderId': senderId,
      'message': message,
    });
  }

  /// Send animated reaction/emoji (matches backend: socket.on('send_reaction', ...))
  void sendReaction(String roomId, String userId, String emoji) {
    _safeEmit('send_reaction', {
      'roomId': roomId,
      'userId': userId,
      'emoji': emoji,
    });
  }

  // ─── Admin Panel Emitters ─────────────────────────────────────────

  void emitAnnouncement(String title, String message) {
    _socket.emit('admin_announcement', {'title': title, 'message': message});
  }

  void emitForceCloseRoom(String roomId) {
    _socket.emit('force_close_room', {'roomId': roomId});
  }

  void emitBanUser(String userId) {
    _socket.emit('ban_user', {'userId': userId});
  }

  // =========================================================================
  // HELPERS
  // =========================================================================

  /// Emit only when connected — silently drop if socket is down
  void _safeEmit(String event, dynamic data) {
    if (isConnected.value) {
      _socket.emit(event, data);
    } else {
      debugPrint('[SocketService] Dropped emit "$event" — socket not connected');
    }
  }

  /// Disconnect the socket
  void disconnect() {
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect
    _socket.disconnect();
  }

  // =========================================================================
  // CLEANUP
  // =========================================================================

  @override
  void onClose() {
    _roomUpdateController.close();
    _userStatusController.close();
    _notificationController.close();
    _withdrawalController.close();
    _reportController.close();
    _ticketController.close();
    _dashboardController.close();
    _banController.close();
    _chatController.close();
    _socket.dispose();
    super.onClose();
  }
}