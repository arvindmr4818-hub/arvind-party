// ═══════════════════════════════════════════════════════════════════════════
// SERVICE: ApiService — HTTP client for Web Panel → Node.js Backend
// All pages use this service to communicate with the backend
// ═══════════════════════════════════════════════════════════════════════════

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/env_config.dart';

class ApiService extends GetxService {
  final _box = GetStorage();

  String get _baseUrl =>
      kDebugMode ? EnvConfig.devApiBaseUrl : EnvConfig.prodApiBaseUrl;

  String? get _token => _box.read('auth_token');

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── GET ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint')
          .replace(queryParameters: queryParams);
      final response =
          await http.get(uri, headers: _headers).timeout(const Duration(seconds: 30));
      return _handle(response);
    } catch (e) {
      return _error(e);
    }
  }

  // ─── POST ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      return _handle(response);
    } catch (e) {
      return _error(e);
    }
  }

  // ─── PUT ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .put(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      return _handle(response);
    } catch (e) {
      return _error(e);
    }
  }

  // ─── DELETE ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response =
          await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 30));
      return _handle(response);
    } catch (e) {
      return _error(e);
    }
  }

  // ─── PATCH ──────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> patch(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .patch(uri, headers: _headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      return _handle(response);
    } catch (e) {
      return _error(e);
    }
  }

  // ─── RESPONSE HANDLER ───────────────────────────────────────────────────
  Map<String, dynamic> _handle(http.Response response) {
    // Token expired
    if (response.statusCode == 401) {
      _box.remove('auth_token');
      Get.offAllNamed('/login');
      return {'success': false, 'message': 'Session expired. Please login again.'};
    }

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }
      return {
        'success': false,
        'message': data['message'] ?? 'Server error ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Invalid server response',
        'statusCode': response.statusCode,
      };
    }
  }

  Map<String, dynamic> _error(dynamic e) {
    debugPrint('ApiService error: $e');
    return {
      'success': false,
      'message': e.toString().contains('Connection refused')
          ? 'Cannot connect to server. Is backend running?'
          : e.toString(),
    };
  }
}
