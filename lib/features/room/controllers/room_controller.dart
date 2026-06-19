// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/controllers/room_controller.dart
// ARVIND PARTY - ROOM CONTROLLER (Full Logic: CRUD, Voice, Seats, Permissions)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../models/room_model.dart';
import '../repositories/room_repository.dart';

class RoomController extends GetxController {
  final RoomRepository _repo = RoomRepository();

  // Observables
  final rooms = <RoomModel>[].obs;
  final currentRoom = Rxn<RoomModel>();
  final members = <RoomMember>[].obs;
  final seats = <MicSeat>[].obs;
  final myMember = Rxn<RoomMember>();
  final isInRoom = false.obs;
  final isLoading = false.obs;

  // Voice states
  final isMuted = true.obs;
  final isSpeaker = false.obs;
  final isEarMonitoring = false.obs;
  final isNoiseCancellation = false.obs;
  final selectedVoiceEffect = VoiceEffect.none.obs;
  final isSpatialAudio = false.obs;

  @override
  void onClose() {
    _repo.disconnectSocket();
    super.onClose();
  }

  // --- ROOM CRUD ---
  Future<void> loadRooms({String? type}) async {
    isLoading.value = true;
    try {
      rooms.assignAll(await _repo.getRooms(type: type));
    } finally { isLoading.value = false; }
  }

  Future<void> createRoom(Map<String, dynamic> data) async {
    final room = await _repo.createRoom(data);
    rooms.add(room);
    Get.snackbar('Success', 'Room created!');
  }

  Future<void> updateRoomSettings(Map<String, dynamic> data) async {
    await _repo.updateRoom(currentRoom.value!.id, data);
    Get.snackbar('Success', 'Settings updated!');
  }

  Future<void> deleteRoom() async {
    await _repo.deleteRoom(currentRoom.value!.id);
    rooms.remove(currentRoom.value);
    Get.offNamed('/rooms');
  }

  // --- JOIN / LEAVE ---
  Future<void> joinRoom(String roomId, {String? password}) async {
    isLoading.value = true;
    try {
      final room = await _repo.joinRoom(roomId, password: password);
      currentRoom.value = room;
      members.assignAll(room.members);
      seats.assignAll(room.seats);
      isInRoom.value = true;
      _repo.connectSocket(roomId, 'currentUserId');
      _listenSocketEvents();
    } catch (e) {
      Get.snackbar('Error', 'Invalid password or room not found');
    } finally { isLoading.value = false; }
  }

  Future<void> leaveRoom() async {
    final roomId = currentRoom.value?.id;
    if (roomId != null) await _repo.leaveRoom(roomId);
    _repo.disconnectSocket();
    isInRoom.value = false;
    currentRoom.value = null;
    Get.back();
  }

  void _listenSocketEvents() {
    _repo.onSeatUpdate((data) {
      final updatedSeat = MicSeat.fromJson(data);
      final index = seats.indexWhere((s) => s.seatId == updatedSeat.seatId);
      if (index != -1) seats[index] = updatedSeat;
      seats.refresh();
    });
    _repo.onMemberUpdate((data) {
      final updatedMember = RoomMember.fromJson(data);
      final index = members.indexWhere((m) => m.userId == updatedMember.userId);
      if (index != -1) members[index] = updatedMember;
      members.refresh();
    });
  }

  // --- VOICE CHAT ACTIONS ---
  void toggleMute() {
    isMuted.value = !isMuted.value;
    _repo.emitVoiceAction('toggle_mute', data: {'userId': myMember.value?.userId, 'mute': isMuted.value});
  }

  void toggleSpeaker() {
    isSpeaker.value = !isSpeaker.value;
    _repo.emitVoiceAction('toggle_speaker', data: {'userId': myMember.value?.userId, 'speaker': isSpeaker.value});
  }

  void toggleEarMonitoring() => isEarMonitoring.value = !isEarMonitoring.value;
  void toggleNoiseCancellation() => isNoiseCancellation.value = !isNoiseCancellation.value;
  void setVoiceEffect(VoiceEffect effect) => selectedVoiceEffect.value = effect;
  void toggleSpatialAudio() => isSpatialAudio.value = !isSpatialAudio.value;

  // --- MIC SEAT ACTIONS ---
  void requestSeat(int seatNumber) {
    _repo.emitSeatAction('request_seat', data: {'seatNumber': seatNumber, 'userId': myMember.value?.userId});
  }

  void lockSeat(String seatId, {bool lock = true}) {
    _repo.emitSeatAction('lock_seat', data: {'seatId': seatId, 'lock': lock});
  }

  void acceptSeatRequest(String userId, int seatNumber) {
    _repo.emitSeatAction('accept_seat', data: {'userId': userId, 'seatNumber': seatNumber});
  }

  void rejectSeatRequest(String userId) {
    _repo.emitSeatAction('reject_seat', data: {'userId': userId});
  }

  void kickFromSeat(String seatId) {
    _repo.emitSeatAction('kick_seat', data: {'seatId': seatId});
  }

  void transferSeat(String seatId, String toUserId) {
    _repo.emitSeatAction('transfer_seat', data: {'seatId': seatId, 'toUserId': toUserId});
  }

  void reserveSeat(int seatNumber, String userId) {
    _repo.emitSeatAction('reserve_seat', data: {'seatNumber': seatNumber, 'userId': userId});
  }

  // --- PERMISSIONS ---
  void updateRole(String userId, PermissionRole newRole) {
    _repo.emitSeatAction('update_role', data: {'userId': userId, 'role': newRole.name});
  }

  void kickMember(String userId) {
    _repo.emitSeatAction('kick_member', data: {'userId': userId});
  }
}