// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/services/room_repository.dart
// ARVIND PARTY - ROOM REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class RoomRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> fetchRooms() async {
    final response = await _api.get('/rooms');
    if (response is Map && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<Map<String, dynamic>> createRoom(Map<String, dynamic> data) async {
    final response = await _api.post('/rooms', body: data);
    if (response is Map<String, dynamic>) return response;
    return <String, dynamic>{};
  }
}
