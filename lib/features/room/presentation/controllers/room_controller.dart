// ═══════════════════════════════════════════════════════════════════════════
// ROOM CONTROLLER — LiveKit + Backend Integration
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/socket/socket_service.dart';
import '../../../home/services/user_service.dart';
import '../../services/room_service.dart';

class RoomController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final SocketService _socket = Get.find<SocketService>();
  final UserService _user = Get.find<UserService>();
  final RoomService _roomService = Get.put(RoomService());

  // ─── State ────────────────────────────────────────────────────────────
  final isLoading = false.obs;
  final currentRoomId = ''.obs;
  final roomName = ''.obs;
  final memberCount = 0.obs;
  final isMicOn = false.obs;
  final isChatOpen = false.obs;
  final isHost = false.obs;

  final seats = <Map<String, dynamic>>[].obs;
  final chatMessages = <Map<String, dynamic>>[].obs;
  final activeSpeakers = <String>[].obs;

  // ─── Join Room ────────────────────────────────────────────────────────
  Future<bool> joinRoom(String roomId) async {
    isLoading.value = true;
    currentRoomId.value = roomId;

    try {
      // 1. Get room info from backend
      final roomRes = await _api.get('/rooms/$roomId');
      if (roomRes['success'] != true) {
        Get.snackbar('Error', roomRes['message'] ?? 'Room not found',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
        isLoading.value = false;
        return false;
      }

      final roomData = Map<String, dynamic>.from(roomRes['data'] ?? {});
      roomName.value = roomData['name'] ?? 'Room';
      isHost.value = roomData['ownerId'] == _user.userId;

      // 2. Load seats
      await _loadSeats(roomId);

      // 3. Join LiveKit
      final role = isHost.value ? 'host' : 'audience';
      final result = await _roomService.joinRoom(roomId: roomId, role: role);
      if (result['success'] != true) {
        Get.snackbar('Voice Error', result['message'] ?? 'Could not join voice',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
      } else {
        isMicOn.value = isHost.value;
      }

      // 4. Join Socket.IO room
      _socket.socket.emit('room:join', {'roomId': roomId, 'userId': _user.userId});
      _setupSocketListeners(roomId);

      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', e.toString());
      return false;
    }
  }

  Future<void> _loadSeats(String roomId) async {
    try {
      final res = await _api.get('/room/$roomId/members');
      if (res['success'] == true) {
        final members = List<Map<String, dynamic>>.from(res['data']?['members'] ?? []);
        memberCount.value = members.length;

        // Build 8-seat layout
        final seatList = List.generate(8, (i) => {
          'seatNumber': i + 1,
          'userId': null, 'userName': null, 'userAvatar': null,
          'isAudioEnabled': true, 'isHost': false,
        });

        for (final m in members) {
          final seatNum = (m['seat'] as int? ?? 0) - 1;
          if (seatNum >= 0 && seatNum < 8) {
            seatList[seatNum] = {
              'seatNumber': seatNum + 1,
              'userId': m['userId'],
              'userName': m['userName'],
              'userAvatar': m['userAvatar'],
              'isAudioEnabled': m['isAudioEnabled'] ?? true,
              'isHost': m['isHost'] ?? false,
            };
          }
        }
        seats.value = seatList;
      }
    } catch (_) {}
  }

  void _setupSocketListeners(String roomId) {
    _socket.socket.on('seat:occupied', (data) {
      if (data['roomId'] == roomId) _loadSeats(roomId);
    });
    _socket.socket.on('seat:vacant', (data) {
      if (data['roomId'] == roomId) _loadSeats(roomId);
    });
    _socket.socket.on('room:message', (data) {
      if (data['roomId'] == roomId) {
        chatMessages.add(Map<String, dynamic>.from(data));
        if (chatMessages.length > 100) chatMessages.removeAt(0);
      }
    });
    _socket.socket.on('room:gift', (data) {
      if (data['roomId'] == roomId) {
        Get.snackbar('🎁 Gift!',
          '${data['senderName']} sent ${data['giftName']}',
          backgroundColor: const Color(0xFFFF8906),
          colorText: Colors.black,
          duration: const Duration(seconds: 3));
      }
    });
    _socket.socket.on('user:kicked', (data) {
      if (data['roomId'] == roomId && data['userId'] == _user.userId) {
        Get.snackbar('Removed', 'You were removed from the room',
          backgroundColor: const Color(0xFFFF4757), colorText: Colors.white);
        leaveRoom();
        Get.back();
      }
    });
  }

  Future<void> onSeatTap(int seatNumber) async {
    final seat = seats.firstWhereOrNull((s) => s['seatNumber'] == seatNumber);
    if (seat == null) return;

    if (seat['userId'] == null) {
      // Take empty seat
      final res = await _api.post('/room/${currentRoomId.value}/seat/occupy', {'seatNumber': seatNumber});
      if (res['success'] == true) {
        isMicOn.value = true;
        await _roomService.enableMicrophone();
        await _loadSeats(currentRoomId.value);
      }
    } else if (seat['userId'] == _user.userId) {
      // Leave seat
      await _api.post('/room/${currentRoomId.value}/seat/leave', {});
      await _roomService.toggleMicrophone();
      isMicOn.value = false;
      await _loadSeats(currentRoomId.value);
    } else if (isHost.value) {
      // Host tapping on another user — show options
      Get.bottomSheet(_HostActionsSheet(
        userId: seat['userId'],
        userName: seat['userName'] ?? '',
        roomId: currentRoomId.value,
        ctrl: this,
      ));
    }
  }

  Future<void> toggleMic() async {
    await _roomService.toggleMicrophone();
    isMicOn.value = !isMicOn.value;
  }

  void toggleChat() => isChatOpen.value = !isChatOpen.value;

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;
    _socket.socket.emit('room:message', {
      'roomId': currentRoomId.value,
      'message': text.trim(),
      'userId': _user.userId,
      'userName': _user.userName,
    });
  }

  Future<void> kickUser(String userId) async {
    await _api.post('/room/${currentRoomId.value}/host/kick', {'targetUserId': userId});
  }

  Future<void> muteUser(String userId) async {
    await _api.post('/room/${currentRoomId.value}/host/mute', {'targetUserId': userId});
  }

  Future<void> leaveRoom() async {
    _socket.socket.emit('room:leave', {'roomId': currentRoomId.value, 'userId': _user.userId});
    _socket.socket.off('seat:occupied');
    _socket.socket.off('seat:vacant');
    _socket.socket.off('room:message');
    _socket.socket.off('room:gift');
    _socket.socket.off('user:kicked');
    await _api.post('/room/${currentRoomId.value}/seat/leave', {});
    await _roomService.leaveRoom();
  }

  @override
  void onClose() { leaveRoom(); super.onClose(); }
}

// Host actions bottom sheet
class _HostActionsSheet extends StatelessWidget {
  final String userId, userName, roomId;
  final RoomController ctrl;
  const _HostActionsSheet({required this.userId, required this.userName, required this.roomId, required this.ctrl});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(color: Color(0xFF1A1928),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    padding: const EdgeInsets.all(20),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 16),
      ListTile(leading: const Icon(Icons.mic_off, color: Colors.orange), title: const Text('Mute', style: TextStyle(color: Colors.white)),
        onTap: () { Get.back(); ctrl.muteUser(userId); }),
      ListTile(leading: const Icon(Icons.person_remove, color: Colors.red), title: const Text('Kick from room', style: TextStyle(color: Colors.white)),
        onTap: () { Get.back(); ctrl.kickUser(userId); }),
      ListTile(leading: const Icon(Icons.close, color: Colors.white54), title: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        onTap: Get.back),
    ]),
  );
}
