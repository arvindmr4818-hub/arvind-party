// lib/core/services/api_service.dart
// Real API service for Arvind Party - connects to Node.js backend
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' as getx;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';

class ApiService extends getx.GetxService {
  late final Dio _dio;
  final GetStorage _storage = GetStorage();

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _storage.read('auth_token') ?? _storage.read('staff_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Log error but don't block
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // ===== TOKEN MANAGEMENT =====
  void saveToken(String token) {
    _storage.write('auth_token', token);
  }

  String? getToken() {
    return _storage.read('auth_token');
  }

  void clearToken() {
    _storage.remove('auth_token');
    _storage.remove('user_data');
  }

  bool isLoggedIn() {
    return _storage.read('auth_token') != null;
  }

  // ===== HTTP METHODS =====
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body, Map<String, dynamic>? query}) async {
    try {
      final response = await _dio.post(endpoint, data: body, queryParameters: query);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.put(endpoint, data: body);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await _dio.delete(endpoint, data: body);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Multipart upload
  Future<dynamic> uploadFile(String endpoint, String filePath, String fieldName, {Map<String, dynamic>? extraFields}) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraFields != null) ...extraFields,
      });
      final response = await _dio.post(endpoint, data: formData);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Connection timeout. Please try again.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check your internet.';
    }
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      return 'Server error: ${e.response?.statusCode}';
    }
    return e.message ?? 'Unknown error';
  }
}
