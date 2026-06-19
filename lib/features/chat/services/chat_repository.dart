// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/services/chat_repository.dart
// ARVIND PARTY - CHAT REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class ChatRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> fetchMessages(String roomId) async {
    final response = await _api.get('/chat/$roomId/messages');
    if (response is Map && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<void> sendMessage(String roomId, String text) async {
    await _api.post('/chat/$roomId/messages', body: {'text': text});
  }
}
