import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../network/admin_api.dart';
import 'api_constants.dart';
import 'role_constants.dart';

// ============================================================
// ARVIND PARTY WEB — Authentication Controller (GetX)
// ============================================================

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final _box = GetStorage();
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  // ─── Reactive State ──────────────────────────────────────
  final isLoggedIn = false.obs;
  final currentUserRole = AppRole.appAdminWeb.obs;
  final currentStaffId = ''.obs;
  final currentStaffName = ''.obs;
  final currentLoginId = ''.obs;
  final currentToken = ''.obs;
  final _permissions = <String, String>{}.obs; // moduleName -> level
  final _loginError = ''.obs;

  String get loginError => _loginError.value;

  // ─── Initialization ──────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final token = _box.read<String>(ApiConstants.tokenStorageKey);
    if (token != null && token.isNotEmpty) {
      final roleStr = _box.read<String>(ApiConstants.roleStorageKey) ?? '';
      final staffId = _box.read<String>('staff_id') ?? '';
      final staffName = _box.read<String>('staff_name') ?? '';
      final loginId = _box.read<String>('staff_login_id') ?? '';

      isLoggedIn.value = true;
      currentUserRole.value = AppRole.fromString(roleStr);
      currentStaffId.value = staffId;
      currentStaffName.value = staffName;
      currentLoginId.value = loginId;
      currentToken.value = token;

      // Load stored permissions
      final storedPerms = _box.read<Map>('staff_permissions');
      if (storedPerms != null) {
        _permissions.assignAll(storedPerms.map((k, v) => MapEntry(k.toString(), v.toString())));
      }
    }
  }

  // ─── Login (Firebase Auth — bypasses Node.js backend) ──
  Future<bool> login(String loginId, String password) async {
    _isLoading.value = true;
    _loginError.value = '';
    try {
      // Use Firebase Auth with email (loginId) and password
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginId,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // Firebase login succeeded — save minimal session
        _saveSession(
          user.uid, // Firebase UID as token
          AppRole.appAdminWeb, // Default role; fetch from backend if needed
          user.uid,
          user.displayName ?? loginId,
          loginId,
          {}, // No permissions yet; fetch from backend if needed
        );

        Get.offAllNamed('/dashboard');
        return true;
      }

      _loginError.value = 'Login failed. No user returned.';
      return false;
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthController] Firebase error: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          _loginError.value = 'No account found with this email.';
          break;
        case 'wrong-password':
          _loginError.value = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          _loginError.value = 'The email address is invalid.';
          break;
        case 'user-disabled':
          _loginError.value = 'This account has been disabled.';
          break;
        case 'too-many-requests':
          _loginError.value = 'Too many attempts. Please try again later.';
          break;
        case 'invalid-credential':
          _loginError.value = 'Invalid email or password. Please try again.';
          break;
        case 'network-request-failed':
          _loginError.value = 'Network error. Check your connection.';
          break;
        default:
          _loginError.value = 'Login failed: ${e.message ?? e.code}';
      }
      return false;
    } catch (e) {
      debugPrint('[AuthController] Login error: $e');
      _loginError.value = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  void _saveSession(
    String token,
    AppRole role,
    String staffId,
    String staffName,
    String loginId,
    Map<String, String> permissions,
  ) {
    _box.write(ApiConstants.tokenStorageKey, token);
    _box.write(ApiConstants.roleStorageKey, role.storageKey);
    _box.write('staff_id', staffId);
    _box.write('staff_name', staffName);
    _box.write('staff_login_id', loginId);
    _box.write('staff_permissions', permissions);

    isLoggedIn.value = true;
    currentUserRole.value = role;
    currentStaffId.value = staffId;
    currentStaffName.value = staffName;
    currentLoginId.value = loginId;
    _permissions.assignAll(permissions);
  }

  // ─── Logout ──────────────────────────────────────────────
  Future<void> logout() async {
    _box.remove(ApiConstants.tokenStorageKey);
    _box.remove(ApiConstants.roleStorageKey);
    _box.remove('staff_id');
    _box.remove('staff_name');
    _box.remove('staff_login_id');
    _box.remove('staff_permissions');

    isLoggedIn.value = false;
    currentUserRole.value = AppRole.appAdminWeb;
    currentStaffId.value = '';
    currentStaffName.value = '';
    currentLoginId.value = '';
    currentToken.value = '';
    _permissions.clear();

    Get.offAllNamed('/login');
  }

  /// Refresh staff permissions from server
  Future<void> refreshPermissions() async {
    try {
      final response = await AdminApi.to.getStaffList();
      if (response.isNotEmpty) {
        // Use first staff entry's permissions if available
        final first = response.first as Map<String, dynamic>?;
        if (first != null && first['permissions'] is Map) {
          final rawPerms = first['permissions'] as Map;
          _permissions.assignAll(rawPerms.map((k, v) => MapEntry(k.toString(), v.toString())));
          _box.write('staff_permissions', rawPerms);
        }
      }
    } catch (e) {
      debugPrint('[AuthController] refreshPermissions error: $e');
    }
  }

  // ─── Permission Check ────────────────────────────────────
  bool hasPermission(String module, {List<String> allowedLevels = const []}) {
    final level = _permissions[module];
    if (level == null) return false;
    if (allowedLevels.isEmpty) return true;
    return allowedLevels.contains(level);
  }

  bool get canAccessDashboard => hasPermission('dashboard');

  /// Returns the permission level for a given module
  String getPermissionLevel(String module) {
    return _permissions[module] ?? 'off';
  }

  /// Checks if the user has at least viewOnly on a module
  bool canView(String module) {
    final level = getPermissionLevel(module);
    return level != 'off';
  }

  /// Checks if the user can edit a module
  bool canEdit(String module) {
    final level = getPermissionLevel(module);
    return level == 'edit' || level == 'fullControl';
  }

  /// Checks if the user has full control over a module
  bool isFullControl(String module) {
    return getPermissionLevel(module) == 'fullControl';
  }

  /// Returns true if the current role is OWNER.WEB
  bool get isOwner => currentUserRole.value == AppRole.ownerWeb;
}