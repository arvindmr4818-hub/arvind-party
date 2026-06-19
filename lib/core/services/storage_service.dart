// lib/core/storage/storage_service.dart
// Uses GetStorage for all persistent storage - SharedPreferences removed
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final GetStorage _storage = GetStorage();

  static StorageService get to => Get.find();

  // TOKEN
  Future<void> saveToken(String token) async {
    await _storage.write('token', token);
  }

  String? getToken() {
    return _storage.read<String>('token');
  }

  Future<void> removeToken() async {
    await _storage.remove('token');
  }

  // USER ID
  Future<void> saveUserId(String userId) async {
    await _storage.write('user_id', userId);
  }

  String? getUserId() {
    return _storage.read<String>('user_id');
  }

  // LOGIN STATUS
  Future<void> setLoggedIn(bool value) async {
    await _storage.write('is_logged_in', value);
  }

  bool isLoggedIn() {
    return _storage.read<bool>('is_logged_in') ?? false;
  }

  // USER DATA
  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _storage.write('user_data', data);
  }

  Map<String, dynamic>? getUserData() {
    final data = _storage.read<Map>('user_data');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  // LOGOUT
  Future<void> logout() async {
    await _storage.remove('token');
    await _storage.remove('user_id');
    await _storage.remove('user_data');
    await _storage.remove('is_logged_in');
  }

  Future<void> clearAll() async {
    await _storage.erase();
  }
}