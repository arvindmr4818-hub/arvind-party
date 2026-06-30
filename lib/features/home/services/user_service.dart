// ═══════════════════════════════════════════════════════════════════════════
// USER SERVICE — Profile, Balance, Session
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';

class UserService extends GetxService {
  final ApiService _api = Get.find<ApiService>();
  final _box = GetStorage();

  // Current user state
  final currentUser = Rx<Map<String, dynamic>?>(null);
  final coins = 0.obs;
  final diamonds = 0.obs;
  final vipLevel = 0.obs;
  final isLoggedIn = false.obs;

  String? get userId => currentUser.value?['_id'];
  String? get userName => currentUser.value?['name'];
  String? get userAvatar => currentUser.value?['avatar'];
  String? get token => _box.read('auth_token');

  @override
  void onInit() {
    super.onInit();
    final saved = _box.read('current_user');
    if (saved != null) {
      currentUser.value = Map<String, dynamic>.from(saved);
      coins.value = saved['coins'] ?? 0;
      diamonds.value = saved['diamonds'] ?? 0;
      vipLevel.value = saved['vipLevel'] ?? 0;
      isLoggedIn.value = token != null;
    }
  }

  Future<bool> fetchProfile() async {
    try {
      final res = await _api.get('/users/me');
      if (res['success'] == true) {
        final user = Map<String, dynamic>.from(res['data'] ?? {});
        currentUser.value = user;
        coins.value = user['coins'] ?? 0;
        diamonds.value = user['diamonds'] ?? 0;
        vipLevel.value = user['vipLevel'] ?? 0;
        _box.write('current_user', user);
        isLoggedIn.value = true;
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> refreshBalance() async {
    try {
      final res = await _api.get('/wallet/balance');
      if (res['success'] == true) {
        coins.value = res['data']?['coins'] ?? coins.value;
        diamonds.value = res['data']?['diamonds'] ?? diamonds.value;
      }
    } catch (_) {}
  }

  void saveSession(Map<String, dynamic> user, String authToken) {
    _box.write('auth_token', authToken);
    _box.write('current_user', user);
    currentUser.value = user;
    coins.value = user['coins'] ?? 0;
    diamonds.value = user['diamonds'] ?? 0;
    vipLevel.value = user['vipLevel'] ?? 0;
    isLoggedIn.value = true;
  }

  Future<void> logout() async {
    try { await _api.post('/auth/logout', {}); } catch (_) {}
    _box.remove('auth_token');
    _box.remove('current_user');
    currentUser.value = null;
    coins.value = 0;
    diamonds.value = 0;
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
