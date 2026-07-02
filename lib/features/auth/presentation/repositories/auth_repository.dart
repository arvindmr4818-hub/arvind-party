import 'package:get/get.dart';
import '../../../../core/services/api_service.dart';

class AuthRepository extends GetxService {
  final ApiService _api = Get.find<ApiService>();

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _api.get('/users/me');
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    return await _api.put('/users/profile', data);
  }

  Future<Map<String, dynamic>> logout() async {
    return await _api.post('/auth/logout', {});
  }
}
