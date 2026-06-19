// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/services/user_repository.dart
// ARVIND PARTY - USER REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class UserRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _api.get('/user/profile') as Map<String, dynamic>? ?? <String, dynamic>{};
    return response;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _api.put('/user/profile', body: data);
  }
}
