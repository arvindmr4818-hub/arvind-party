// ═══════════════════════════════════════════════════════════════════════════
// WEB AUTH CONTROLLER — REAL BACKEND CONNECTED
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/env_config.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();
  final _storage = GetStorage();

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var adminName = ''.obs;
  var adminEmail = ''.obs;
  var role = ''.obs;

  String get _baseUrl => kDebugMode ? EnvConfig.devApiBaseUrl : EnvConfig.prodApiBaseUrl;

  @override
  void onInit() {
    super.onInit();
    _checkSession();
  }

  void _checkSession() {
    final token = _storage.read('auth_token');
    if (token != null && token.toString().isNotEmpty) {
      isLoggedIn.value = true;
      adminName.value = _storage.read('admin_name') ?? 'Admin';
      adminEmail.value = _storage.read('admin_email') ?? '';
      role.value = _storage.read('admin_role') ?? 'admin';
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      if (username.isEmpty || password.isEmpty) {
        errorMessage.value = 'Username and password are required';
        return false;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/auth/admin-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']?['token'] ?? data['token'];
        final user = data['data']?['user'] ?? data['user'] ?? {};

        _storage.write('auth_token', token);
        _storage.write('admin_name', user['name'] ?? username);
        _storage.write('admin_email', user['email'] ?? '');
        _storage.write('admin_role', user['role'] ?? 'admin');
        _storage.write('admin_id', user['_id'] ?? '');

        isLoggedIn.value = true;
        adminName.value = user['name'] ?? username;
        adminEmail.value = user['email'] ?? '';
        role.value = user['role'] ?? 'admin';

        return true;
      } else {
        errorMessage.value = data['message'] ?? 'Invalid credentials';
        return false;
      }
    } on http.ClientException catch (e) {
      errorMessage.value = 'Cannot connect to server. Check backend is running.';
      debugPrint('Login error: $e');
      return false;
    } catch (e) {
      errorMessage.value = 'Login failed: ${e.toString()}';
      debugPrint('Login error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      final token = _storage.read('auth_token');
      if (token != null) {
        await http.post(
          Uri.parse('$_baseUrl/auth/logout'),
          headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        ).timeout(const Duration(seconds: 10));
      }
    } catch (_) {}

    _storage.remove('auth_token');
    _storage.remove('admin_name');
    _storage.remove('admin_email');
    _storage.remove('admin_role');
    _storage.remove('admin_id');

    isLoggedIn.value = false;
    adminName.value = '';
    adminEmail.value = '';
    role.value = '';

    Get.offAllNamed('/login');
  }

  bool get isOwner => role.value == 'owner' || role.value == 'super_admin';
  bool get isAdmin => ['owner', 'super_admin', 'admin'].contains(role.value);
  bool get isModerator => ['owner', 'super_admin', 'admin', 'moderator'].contains(role.value);
}
