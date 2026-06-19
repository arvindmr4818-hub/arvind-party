// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/repositories/room_repository.dart
// ARVIND PARTY - ROOM REPOSITORY (API + Socket + Mock Data)
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/constants/env_config.dart';
import '../models/room_model.dart';

class RoomRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));
  IO.Socket? _socket;

  // --- REST API ---
  Future<List<RoomModel>> getRooms({String? type}) async {
    try {
      final response = await _dio.get('/rooms', queryParameters: {'type': type});
      return (response.data['data'] as List)
          .map((e) => RoomModel.fromJson(e))
          .toList();
    } catch (e) { return _mockRooms(type); }
  }

  Future<RoomModel> createRoom(Map<String, dynamic> data) async {
    final response = await _dio.post('/rooms', data: data);
    return RoomModel.fromJson(response.data['data']);
  }

  Future<void> updateRoom(String roomId, Map<String, dynamic> data) async {
    await _dio.put('/rooms/$roomId', data: data);
  }

  Future<void> deleteRoom(String roomId) async {
    await _dio.delete('/rooms/$roomId');
  }

  Future<RoomModel> joinRoom(String roomId, {String? password}) async {
    final response = await _dio.post('/rooms/$roomId/join', data: {'password': password});
    return RoomModel.fromJson(response.data['data']);
  }

  Future<void> leaveRoom(String roomId) async => await _dio.post('/rooms/$roomId/leave');

  // --- SOCKET.IO (Real-time Voice & Seats) ---
  void connectSocket(String roomId, String userId) {
    _socket = IO.io(EnvConfig.socketUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .build());
    _socket!.connect();
    _socket!.emit('join_room', {'roomId': roomId, 'userId': userId});
  }

  void emitVoiceAction(String action, {Map<String, dynamic>? data}) => _socket?.emit(action, data);
  void emitSeatAction(String action, {Map<String, dynamic>? data}) => _socket?.emit(action, data);
  void onSeatUpdate(Function(dynamic) callback) => _socket?.on('seat_update', callback);
  void onMemberUpdate(Function(dynamic) callback) => _socket?.on('member_update', callback);
  void disconnectSocket() => _socket?.disconnect();

  // --- MOCK DATA ---
  List<RoomModel> _mockRooms(String? type) {
    final mockSettings = RoomSettings(tags: ['Music', 'Chill'], rules: 'Be respectful');
    final mockMembers = [
      RoomMember(userId: 'h1', username: 'HostUser', role: PermissionRole.owner),
      RoomMember(userId: 'u2', username: 'AdminUser', role: PermissionRole.admin),
    ];
    final mockSeats = List.generate(10, (i) => MicSeat(
      seatId: 's$i', seatNumber: i + 1,
      status: i == 0 ? SeatStatus.occupied : SeatStatus.empty,
      occupiedByUserId: i == 0 ? 'h1' : null,
      isHostSeat: i == 0,
    ));
    final allTypes = RoomType.values;
    return List.generate(10, (index) {
      final rType = type != null ? RoomType.values.firstWhere((e) => e.name == type) : allTypes[index % allTypes.length];
      return RoomModel(
        id: 'room_$index', name: '${rType.name} Room ${index + 1}',
        type: rType, hostId: 'h1', settings: mockSettings,
        createdAt: DateTime.now(), members: mockMembers, seats: mockSeats,
      );
    });
  }
}