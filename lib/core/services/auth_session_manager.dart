// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/core/services/auth_session_manager.dart
// ARVIND PARTY - CENTRALIZED AUTH SESSION MANAGER
// Single source of truth for all auth tokens and session data
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthSessionManager extends GetxService {
  final GetStorage _storage = GetStorage();

  // Observable session state
  final isLoggedIn = false.obs;
  final currentUserId = ''.obs;
  final currentUserName = ''.obs;
  final currentUserAvatar = ''.obs;
  final currentUserPhone = ''.obs;
  final currentUserEmail = ''.obs;

  // Singleton token keys - SINGLE SOURCE OF TRUTH
  static const String tokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String userNameKey = 'user_name';
  static const String userAvatarKey = 'user_avatar';
  static const String userPhoneKey = 'user_phone';
  static const String userEmailKey = 'user_email';
  static const String loggedInKey = 'is_logged_in';

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  void _loadSession() {
    final token = _storage.read<String>(tokenKey);
    isLoggedIn.value = token != null && token.isNotEmpty;
    currentUserId.value = _storage.read<String>(userIdKey) ?? '';
    currentUserName.value = _storage.read<String>(userNameKey) ?? '';
    currentUserAvatar.value = _storage.read<String>(userAvatarKey) ?? '';
    currentUserPhone.value = _storage.read<String>(userPhoneKey) ?? '';
    currentUserEmail.value = _storage.read<String>(userEmailKey) ?? '';
  }

  // ===== TOKEN MANAGEMENT =====

  String? get token => _storage.read<String>(tokenKey);
  String? get userId => _storage.read<String>(userIdKey);
  String? get userName => _storage.read<String>(userNameKey);
  String? get userAvatar => _storage.read<String>(userAvatarKey);
  String? get userPhone => _storage.read<String>(userPhoneKey);
  String? get userEmail => _storage.read<String>(userEmailKey);

  Future<void> saveSession({
    required String token,
    String userId = '',
    String userName = '',
    String userAvatar = '',
    String userPhone = '',
    String userEmail = '',
  }) async {
    await _storage.write(tokenKey, token);
    await _storage.write(userIdKey, userId);
    await _storage.write(userNameKey, userName);
    await _storage.write(userAvatarKey, userAvatar);
    await _storage.write(userPhoneKey, userPhone);
    await _storage.write(userEmailKey, userEmail);
    await _storage.write(loggedInKey, true);
    _loadSession();
  }

  Future<void> updateProfile({
    String? userName,
    String? userAvatar,
    String? userPhone,
    String? userEmail,
  }) async {
    if (userName != null) {
      await _storage.write(userNameKey, userName);
      currentUserName.value = userName;
    }
    if (userAvatar != null) {
      await _storage.write(userAvatarKey, userAvatar);
      currentUserAvatar.value = userAvatar;
    }
    if (userPhone != null) {
      await _storage.write(userPhoneKey, userPhone);
      currentUserPhone.value = userPhone;
    }
    if (userEmail != null) {
      await _storage.write(userEmailKey, userEmail);
      currentUserEmail.value = userEmail;
    }
  }

  Future<void> clearSession() async {
    await _storage.remove(tokenKey);
    await _storage.remove(userIdKey);
    await _storage.remove(userNameKey);
    await _storage.remove(userAvatarKey);
    await _storage.remove(userPhoneKey);
    await _storage.remove(userEmailKey);
    await _storage.write(loggedInKey, false);
    isLoggedIn.value = false;
    currentUserId.value = '';
    currentUserName.value = '';
    currentUserAvatar.value = '';
    currentUserPhone.value = '';
    currentUserEmail.value = '';
  }

  bool hasToken() => token != null && token!.isNotEmpty;
}