// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/gift/services/gift_repository.dart
// ARVIND PARTY - GIFT REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class GiftRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<List<Map<String, dynamic>>> fetchGifts() async {
    final response = await _api.get('/gifts');
    if (response is Map && response['data'] is List) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<void> sendGift(String giftId, String roomId, String recipientId) async {
    await _api.post('/gifts/send', body: {
      'giftId': giftId,
      'roomId': roomId,
      'recipientId': recipientId,
    });
  }
}
