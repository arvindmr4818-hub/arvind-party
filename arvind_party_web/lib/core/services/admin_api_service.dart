import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api_constants.dart';

class AdminApiService extends GetxService {
  final _storage = GetStorage();

  String get _token => _storage.read<String>('admin_token') ?? '';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  // ─── AUTH ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConstants.adminBaseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return jsonDecode(res.body);
  }

  // ─── DASHBOARD ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getDashboard() async {
    final res = await http.get(
      Uri.parse('${ApiConstants.adminBaseUrl}/dashboard'),
      headers: _headers,
    );
    return jsonDecode(res.body);
  }

  // ─── USERS ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getUsers({int page = 1, String search = '', bool blocked = false}) async {
    final url = '${ApiConstants.adminBaseUrl}/users?page=$page&search=$search&blocked=$blocked';
    final res = await http.get(Uri.parse(url), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<void> blockUser(String id) async {
    await http.patch(Uri.parse('${ApiConstants.adminBaseUrl}/users/$id/block'), headers: _headers);
  }

  Future<void> unblockUser(String id) async {
    await http.patch(Uri.parse('${ApiConstants.adminBaseUrl}/users/$id/unblock'), headers: _headers);
  }

  Future<void> addCoins(String id, int amount) async {
    await http.post(
      Uri.parse('${ApiConstants.adminBaseUrl}/users/$id/coins'),
      headers: _headers,
      body: jsonEncode({'amount': amount}),
    );
  }

  // ─── ROOMS ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getRooms({int page = 1, String? status}) async {
    var url = '${ApiConstants.adminBaseUrl}/rooms?page=$page';
    if (status != null) url += '&status=$status';
    final res = await http.get(Uri.parse(url), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<void> banRoom(String id) async {
    await http.patch(Uri.parse('${ApiConstants.adminBaseUrl}/rooms/$id/ban'), headers: _headers);
  }

  Future<void> closeRoom(String id) async {
    await http.patch(Uri.parse('${ApiConstants.adminBaseUrl}/rooms/$id/close'), headers: _headers);
  }

  // ─── GIFTS ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getGifts() async {
    final res = await http.get(Uri.parse('${ApiConstants.adminBaseUrl}/gifts'), headers: _headers);
    return jsonDecode(res.body);
  }

  Future<void> createGift(Map<String, dynamic> data) async {
    await http.post(
      Uri.parse('${ApiConstants.adminBaseUrl}/gifts'),
      headers: _headers,
      body: jsonEncode(data),
    );
  }

  Future<void> updateGift(String id, Map<String, dynamic> data) async {
    await http.put(
      Uri.parse('${ApiConstants.adminBaseUrl}/gifts/$id'),
      headers: _headers,
      body: jsonEncode(data),
    );
  }

  Future<void> deleteGift(String id) async {
    await http.delete(Uri.parse('${ApiConstants.adminBaseUrl}/gifts/$id'), headers: _headers);
  }

  // ─── ANNOUNCEMENT ──────────────────────────────────────────────────────

  Future<void> sendAnnouncement(String message) async {
    await http.post(
      Uri.parse('${ApiConstants.adminBaseUrl}/announcement'),
      headers: _headers,
      body: jsonEncode({'message': message}),
    );
  }
}
