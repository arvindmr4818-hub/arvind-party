import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;

  // Connection state observable
  final isConnected = false.obs;

  IO.Socket get socket {
    if (_socket == null) {
      throw Exception('SocketService: connect() pehle call karo!');
    }
    return _socket!;
  }

  @override
  void onInit() {
    super.onInit();
    // App open hote hi connect karo
    connect();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  void connect() {
    if (_socket != null && _socket!.connected) return;

    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.onConnect((_) {
      isConnected.value = true;
      debugPrint('[Socket] Connected ✅');
    });

    _socket!.onDisconnect((_) {
      isConnected.value = false;
      debugPrint('[Socket] Disconnected ❌');
    });

    _socket!.onConnectError((err) {
      isConnected.value = false;
      debugPrint('[Socket] Connection Error: $err');
    });

    _socket!.onError((err) {
      debugPrint('[Socket] Error: $err');
    });

    _socket!.connect();
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    isConnected.value = false;
  }

  // ─── ROOM EVENTS ─────────────────────────────────────────────────────────

  void joinRoom(String roomId, String userId, String userName) {
    if (!isConnected.value) return;
    _socket!.emit('join_room', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
    });
  }

  void leaveRoom(String roomId, String userId) {
    if (!isConnected.value) return;
    _socket!.emit('leave_room', {
      'roomId': roomId,
      'userId': userId,
    });
  }

  void sendMessage(
      String roomId, String senderId, String senderName, String message) {
    if (!isConnected.value) return;
    _socket!.emit('send_message', {
      'roomId': roomId,
      'senderId': senderId,
      'senderName': senderName,
      'message': message,
    });
  }

  // ─── GIFT ENGINE ─────────────────────────────────────────────────────────

  void sendGift(String roomId, String senderId, String receiverId,
      String giftId, int quantity) {
    if (!isConnected.value) return;
    _socket!.emit('send_gift', {
      'roomId': roomId,
      'senderId': senderId,
      'receiverId': receiverId,
      'giftId': giftId,
      'quantity': quantity,
    });
  }

  // ─── SEAT ENGINE ─────────────────────────────────────────────────────────

  void raiseHand(String roomId, String userId, String userName) {
    if (!isConnected.value) return;
    _socket!.emit('raise_hand', {
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
    });
  }

  void approveRaiseHand(String roomId, String requestId, String userId) {
    if (!isConnected.value) return;
    _socket!.emit('approve_raise_hand', {
      'roomId': roomId,
      'requestId': requestId,
      'userId': userId,
    });
  }

  void joinSeat(String roomId, int seatNumber, String userId, String userName) {
    if (!isConnected.value) return;
    _socket!.emit('join_seat', {
      'roomId': roomId,
      'seatNumber': seatNumber,
      'userId': userId,
      'userName': userName,
    });
  }

  void leaveSeat(String roomId, int seatNumber) {
    if (!isConnected.value) return;
    _socket!.emit('leave_seat', {
      'roomId': roomId,
      'seatNumber': seatNumber,
    });
  }

  void lockSeat(String roomId, int seatNumber) {
    if (!isConnected.value) return;
    _socket!.emit('lock_seat', {'roomId': roomId, 'seatNumber': seatNumber});
  }

  void unlockSeat(String roomId, int seatNumber) {
    if (!isConnected.value) return;
    _socket!.emit('unlock_seat', {'roomId': roomId, 'seatNumber': seatNumber});
  }

  void muteSeat(String roomId, int seatNumber) {
    if (!isConnected.value) return;
    _socket!.emit('mute_seat', {'roomId': roomId, 'seatNumber': seatNumber});
  }

  void unmuteSeat(String roomId, int seatNumber) {
    if (!isConnected.value) return;
    _socket!.emit('unmute_seat', {'roomId': roomId, 'seatNumber': seatNumber});
  }

  // ─── LISTENERS ───────────────────────────────────────────────────────────

  void onRoomMessage(Function(dynamic) callback) {
    _socket?.on('room_message', callback);
  }

  void onRoomOnlineUpdate(Function(dynamic) callback) {
    _socket?.on('room_online_update', callback);
  }

  void onReceiveMessage(Function(dynamic) callback) {
    _socket?.on('receive_message', callback);
  }

  void onNewRaiseHand(Function(dynamic) callback) {
    _socket?.on('new_raise_hand', callback);
  }

  void onRaiseHandApproved(Function(dynamic) callback) {
    _socket?.on('raise_hand_approved', callback);
  }

  void onSeatUpdated(Function(dynamic) callback) {
    _socket?.on('seat_updated', callback);
  }

  void onGiftAnimation(Function(dynamic) callback) {
    _socket?.on('gift_animation', callback);
  }

  void onGiftError(Function(dynamic) callback) {
    _socket?.on('gift_error', callback);
  }

  // Listener hata do jab screen dispose ho
  void offEvent(String event) {
    _socket?.off(event);
  }
}
