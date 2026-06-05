import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  static StorageService get to => Get.find();

  static const String tokenKey = 'token';
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String loginKey = 'is_logged_in';

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // TOKEN

  Future<void> saveToken(String token) async {
    await _prefs.setString(tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(tokenKey);
  }

  // USER ID

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(userIdKey);
  }

  // LOGIN STATUS

  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(loginKey, value);
  }

  bool isLoggedIn() {
    return _prefs.getBool(loginKey) ?? false;
  }

  // USER DATA

  Future<void> saveUserData(Map<String, dynamic> data) async {
    await _prefs.setString(
      userDataKey,
      jsonEncode(data),
    );
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(userDataKey);

    if (data == null) return null;

    return jsonDecode(data);
  }

  // LOGOUT

  Future<void> logout() async {
    await _prefs.remove(tokenKey);
    await _prefs.remove(userIdKey);
    await _prefs.remove(userDataKey);
    await _prefs.remove(loginKey);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
