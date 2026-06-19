// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/services/wallet_repository.dart
// ARVIND PARTY - WALLET REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class WalletRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> fetchBalance() async {
    final response = await _api.get('/wallet/balance');
    if (response is Map<String, dynamic>) return response;
    if (response is Map) return Map<String, dynamic>.from(response);
    return {'coins': 0, 'diamonds': 0};
  }

  Future<void> withdraw(Map<String, dynamic> data) async {
    await _api.post('/wallet/withdraw', body: data);
  }
}
