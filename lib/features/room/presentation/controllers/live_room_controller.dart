// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/controllers/live_room_controller.dart
// ARVIND PARTY - LIVE STREAMING CONTROLLER (with stub for Agora)
// Agora activated when package is added
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:get_storage/get_storage.dart';
import '../../../../../core/constants/env_config.dart';
import '../../../../../core/services/api_service.dart';
import '../../models/room_models.dart';
import '../../services/seat_layout_service.dart';

class LiveRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ─── Room Identity ──────────────────────────────────────────
  final String roomId;
  final String roomOwnerId;
  final int initialSeatCount;
  io.Socket? socket;

  String get currentUserId => _storage.read('user_id') ?? '';
  String get currentUserName => _storage.read('user_name') ?? 'Guest';
  String get currentUserAvatar => _storage.read('user_avatar') ?? '';

  // ─── Connection States ──────────────────────────────────────
  final isConnected = false.obs;
  final isAgoraInitialized = false.obs;
  final agoraError = Rxn<String>();
  final connectionRetryCount = 0.obs;
  static const int maxRetries = 3;
  Timer? _reconnectTimer;

  // ─── Chat ───────────────────────────────────────────────────
  final chatMessages = <ChatMessage>[].obs;

  // ─── Seats (Dynamic 8-30) ──────────────────────────────────
  final seats = <SeatData>[].obs;
  final seatCount = 0.obs;
  final activeSeat = Rxn<int>();

  // ─── Gift System ───────────────────────────────────────────
  final activeGiftAnimation = Rxn<GiftAnimation>();
  final availableGifts = <Map<String, dynamic>>[].obs;

  // ─── Audio/Video Control ───────────────────────────────────
  final isMuted = false.obs;
  final isVideoEnabled = false.obs;
  final isSpeakerEnabled = true.obs;

  // ─── Remote Users (Agora) ──────────────────────────────────
  final remoteVideoUids = <int>[].obs;
  final mutedRemoteUsers = <int>[].obs;

  // ─── Moderation ─────────────────────────────────────────────
  final kickedUsersList = <Map<String, dynamic>>[].obs;
  final mutedUsersList = <Map<String, dynamic>>[].obs;

  LiveRoomController({
    required this.roomId,
    required this.roomOwnerId,
    this.initialSeatCount = 12,
  });

  @override
  void onInit() {
    super.onInit();
    _initializeSeats(initialSeatCount);
    _initSocket();
    _fetchAvailableGifts();
    debugPrint('[LiveRoom] Agora SDK not included. Using stub.');
    isAgoraInitialized.value = true;
  }

  /// Initialize dynamic seat layout (8-30 seats) using SeatLayoutService
  void _initializeSeats(int count) {
    final validCount = SeatLayoutService.availableSeatCounts.contains(count)
        ? count
        : SeatLayoutService.availableSeatCounts
            .reduce((a, b) => (a - count).abs() < (b - count).abs() ? a : b);
    seatCount.value = validCount;
    seats.assignAll(
      SeatLayoutService.generateInitialSeats(validCount)
          .map((s) => SeatData(
            index: s.index,
            userId: s.userId,
            userName: s.userName,
            isLocked: s.isLocked,
            isMuted: s.isMuted,
          ))
          .toList(),
    );
  }

  /// Update seat layout dynamically (owner only)
  Future<void> changeSeatLayout(int newCount) async {
    if (currentUserId != roomOwnerId) {
      Get.snackbar('Access Denied', 'Only room owner can change seat layout',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (!SeatLayoutService.availableSeatCounts.contains(newCount)) return;
    seatCount.value = newCount;
    _initializeSeats(newCount);
    socket?.emit('update_seat_layout', {
      'roomId': roomId,
      'seatCount': newCount,
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // SOCKET CONNECTION - REAL-TIME COMMUNICATION
  // ══════════════════════════════════════════════════════════════════

  void _initSocket() {
    try {
      final userId = _storage.read('user_id');
      if (userId == null) {
        Get.snackbar('Error', 'You are not logged in.', backgroundColor: Colors.redAccent);
        return;
      }

      final serverUrl = _storage.read('socket_url') ?? EnvConfig.socketUrl;
      socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .build(),
      );
      socket!.connect();

      socket!.onConnect((_) {
        debugPrint('[Socket] Connected to live room server');
        isConnected.value = true;
        socket!.emit('join_room', {
          'roomId': roomId,
          'userId': userId,
          'userProfile': {'name': currentUserName, 'avatar': currentUserAvatar},
        });
      });

      socket!.onDisconnect((_) {
        debugPrint('[Socket] Disconnected');
        isConnected.value = false;
      });

      socket!.onConnectError((data) {
        debugPrint('[Socket] Connection error: $data');
        isConnected.value = false;
      });

      _registerSocketEventListeners();
    } catch (e) {
      debugPrint('[Socket] Initialization failed: $e');
    }
  }

  void _registerSocketEventListeners() {
    socket!.on('receive_room_message', (data) {
      if (data is Map) {
        chatMessages.insert(0, ChatMessage.fromJson(Map<String, dynamic>.from(data)));
      }
    });

    socket!.on('seat_updated', (data) {
      if (data is Map) {
        if (data['seats'] is List) {
          final List<dynamic> jsonSeats = data['seats'];
          final currentCount = seatCount.value;
          final updatedSeats = jsonSeats
              .map((s) => SeatData.fromJson(Map<String, dynamic>.from(s)))
              .where((s) => s.index < currentCount)
              .toList();
          seats.assignAll(updatedSeats);
        } else {
          final updatedSeat = SeatData.fromJson(Map<String, dynamic>.from(data));
          final index = seats.indexWhere((s) => s.index == updatedSeat.index);
          if (index != -1) {
            seats[index] = updatedSeat;
          } else if (updatedSeat.index < seatCount.value) {
            seats.add(updatedSeat);
          }
        }
      }
    });

    socket!.on('seat_layout_changed', (data) {
      if (data is Map && data['seatCount'] != null) {
        _initializeSeats(data['seatCount'] as int);
      }
    });

    socket!.on('gift_animation', (data) {
      if (data is Map) {
        activeGiftAnimation.value = GiftAnimation(
          giftId: data['giftId']?.toString() ?? '',
          giftName: data['giftName']?.toString() ?? 'Gift',
          giftImageUrl: data['giftImageUrl']?.toString() ?? '',
          senderName: data['senderName']?.toString() ?? 'Unknown',
          quantity: data['quantity'] ?? 1,
        );
        Future.delayed(const Duration(seconds: 4), () {
          activeGiftAnimation.value = null;
        });
      }
    });

    socket!.on('system_announcement', (data) {
      if (data is Map) {
        Get.snackbar(
          data['title']?.toString() ?? 'System Notice',
          data['message']?.toString() ?? '',
          backgroundColor: Colors.blueAccent.withValues(alpha: 0.95),
          colorText: Colors.white,
          icon: const Icon(Icons.campaign, color: Colors.white, size: 28),
          duration: const Duration(seconds: 8),
          margin: const EdgeInsets.all(16),
        );
      }
    });

    socket!.on('user_kicked', (data) {
      if (data is Map && data['targetUserId']?.toString() == currentUserId) {
        Get.defaultDialog(
          title: 'Kicked from Room',
          middleText: 'You have been removed from the room by the owner.',
          textConfirm: 'OK',
          confirmTextColor: Colors.white,
          buttonColor: Colors.redAccent,
          barrierDismissible: false,
          onConfirm: () {
            Get.back();
            Get.back();
          },
        );
      }
    });

    socket!.on('user_admin_muted', (data) {
      if (data is Map && data['targetUserId']?.toString() == currentUserId) {
        Get.snackbar('Muted', 'You have been muted by the room owner.',
            backgroundColor: Colors.redAccent, colorText: Colors.white);
        if (!isMuted.value) {
          isMuted.value = true;
        }
      }
    });

    socket!.on('raise_hand_notification', (data) {
      if (data is Map) {
        Get.snackbar(
          'Raise Hand',
          '${data['userName'] ?? 'Someone'} wants to speak',
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    });

    socket!.on('room_closed', (data) {
      Get.defaultDialog(
        title: 'Room Closed',
        middleText: 'This room has been closed by the owner.',
        textConfirm: 'OK',
        confirmTextColor: Colors.white,
        buttonColor: Colors.redAccent,
        barrierDismissible: false,
        onConfirm: () {
          Get.back();
          Get.back();
        },
      );
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // CHAT & GIFTS
  // ══════════════════════════════════════════════════════════════════

  void sendChatMessage(String text) {
    if (text.trim().isEmpty || socket == null || !isConnected.value) return;
    socket!.emit('send_room_message', {
      'roomId': roomId,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'message': text.trim(),
      'isVip': _storage.read('is_vip') ?? false,
    });
  }

  void _fetchAvailableGifts() async {
    try {
      final response = await _apiService.get('/gifts');
      if (response is Map && response['success'] == true) {
        final list = response['data'] as List? ?? response['gifts'] as List? ?? [];
        availableGifts.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (e) {
      debugPrint('[Gifts] Fetch error: $e');
    }
  }

  Future<void> fetchModerationList() async {
    if (currentUserId != roomOwnerId) return;
    try {
      final response = await _apiService.get('/rooms/$roomId/moderation');
      if (response is Map && response['success'] == true) {
        final data = response['data'] as Map? ?? {};
        kickedUsersList.assignAll(
          (data['kickedUsers'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
        );
        mutedUsersList.assignAll(
          (data['mutedUsers'] as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList(),
        );
      }
    } catch (e) {
      debugPrint('[Moderation] Fetch error: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════
  // SEAT MANAGEMENT
  // ══════════════════════════════════════════════════════════════════

  Future<void> joinSeat(int seatIndex) async {
    if (socket == null || !isConnected.value) return;
    if (seatIndex < 0 || seatIndex >= seats.length) return;
    if (seats[seatIndex].isOccupied) {
      Get.snackbar('Seat Taken', 'This seat is already occupied',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    seats[seatIndex] = seats[seatIndex].copyWith(
      userId: currentUserId,
      userName: currentUserName,
      userAvatar: currentUserAvatar,
      role: currentUserId == roomOwnerId ? 'owner' : 'broadcaster',
    );
    activeSeat.value = seatIndex;
    socket!.emit('claim_seat', {
      'roomId': roomId,
      'userId': currentUserId,
      'userName': currentUserName,
      'userAvatar': currentUserAvatar,
      'seatIndex': seatIndex,
    });
  }

  Future<void> leaveSeat() async {
    final idx = activeSeat.value;
    if (idx == null || idx < 0 || idx >= seats.length) return;
    seats[idx] = seats[idx].copyWith(
      userId: null, userName: null, userAvatar: null, role: 'empty',
    );
    activeSeat.value = null;
    isMuted.value = false;
    socket!.emit('leave_seat', {'roomId': roomId, 'seatIndex': idx});
  }

  void toggleLockSeat(int seatIndex) {
    if (currentUserId != roomOwnerId || seatIndex < 0 || seatIndex >= seats.length) return;
    final newLocked = !seats[seatIndex].isLocked;
    seats[seatIndex] = seats[seatIndex].copyWith(isLocked: newLocked);
    socket!.emit(newLocked ? 'lock_seat' : 'unlock_seat', {
      'roomId': roomId, 'seatIndex': seatIndex,
    });
  }

  void muteSeat(int seatIndex) {
    if (currentUserId != roomOwnerId || seatIndex < 0 || seatIndex >= seats.length) return;
    seats[seatIndex] = seats[seatIndex].copyWith(isMuted: true);
    socket!.emit('admin_mute_seat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  void unmuteSeat(int seatIndex) {
    if (currentUserId != roomOwnerId || seatIndex < 0 || seatIndex >= seats.length) return;
    seats[seatIndex] = seats[seatIndex].copyWith(isMuted: false);
    socket!.emit('admin_unmute_seat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  void kickFromSeat(int seatIndex) {
    if (currentUserId != roomOwnerId || seatIndex < 0 || seatIndex >= seats.length) return;
    seats[seatIndex] = seats[seatIndex].copyWith(
      userId: null, userName: null, userAvatar: null, isMuted: false, role: 'empty',
    );
    if (activeSeat.value == seatIndex) activeSeat.value = null;
    socket!.emit('kick_from_seat', {'roomId': roomId, 'seatIndex': seatIndex});
  }

  void transferSeat(int fromSeatIndex, String toUserId, String toUserName, String toUserAvatar) {
    if (currentUserId != roomOwnerId || fromSeatIndex < 0 || fromSeatIndex >= seats.length) return;
    seats[fromSeatIndex] = seats[fromSeatIndex].copyWith(
      userId: toUserId, userName: toUserName, userAvatar: toUserAvatar,
    );
    socket!.emit('transfer_seat', {
      'roomId': roomId, 'seatIndex': fromSeatIndex, 'toUserId': toUserId,
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // AUDIO/VIDEO CONTROLS (stub - Agora can be added later)
  // ══════════════════════════════════════════════════════════════════

  void toggleMute() {
    isMuted.value = !isMuted.value;
    socket?.emit('toggle_mic', {
      'roomId': roomId, 'userId': currentUserId, 'isMuted': isMuted.value,
    });
  }

  void toggleVideo() {
    isVideoEnabled.value = !isVideoEnabled.value;
    socket?.emit('toggle_video', {
      'roomId': roomId, 'userId': currentUserId, 'isVideoEnabled': isVideoEnabled.value,
    });
  }

  void toggleSpeaker() {
    isSpeakerEnabled.value = !isSpeakerEnabled.value;
  }

  // ══════════════════════════════════════════════════════════════════
  // GIFT & ROOM CONTROLS
  // ══════════════════════════════════════════════════════════════════

  void sendGiftToRoom(Map<String, dynamic> giftData) {
    if (socket == null || !isConnected.value) return;
    socket!.emit('send_gift', {
      'roomId': roomId,
      'senderId': currentUserId,
      'senderName': currentUserName,
      'receiverId': roomOwnerId,
      'giftId': giftData['id']?.toString() ?? '',
      'giftName': giftData['name']?.toString() ?? 'Gift',
      'quantity': giftData['quantity'] ?? 1,
      'cost': giftData['cost'] ?? 0,
    });
  }

  void raiseHand() {
    if (socket == null || !isConnected.value) return;
    socket!.emit('raise_hand', {
      'roomId': roomId, 'userId': currentUserId, 'userName': currentUserName,
    });
    Get.snackbar('Hand Raised', 'Waiting for host approval',
        backgroundColor: Colors.orangeAccent, colorText: Colors.white,
        duration: const Duration(seconds: 2));
  }

  Future<void> closeRoomEnvironment() async {
    if (currentUserId != roomOwnerId) {
      Get.snackbar('Access Denied', 'Only the room owner can close the room',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    socket?.emit('close_room', {'roomId': roomId, 'ownerId': currentUserId});
    Get.back();
  }

  void closeRoom() {
    if (currentUserId != roomOwnerId) {
      Get.snackbar('Access Denied', 'Only the room owner can close the room',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    socket!.emit('close_room', {'roomId': roomId, 'ownerId': currentUserId});
    Get.back();
  }

  @override
  void onClose() {
    _reconnectTimer?.cancel();
    if (socket != null) {
      if (isConnected.value) {
        socket!.emit('leave_room', {'roomId': roomId, 'userId': currentUserId});
      }
      socket!.disconnect();
      socket!.dispose();
    }
    super.onClose();
  }
}