// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/repositories/auth_repository.dart
// ARVIND PARTY - AUTH REPOSITORY (REST API with Dio + AuthSessionManager)
// MATCHES BACKEND: /api/auth/send-otp, /api/auth/otp-verify, /api/auth/register, /api/auth/logout, /api/auth/me
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../../core/constants/env_config.dart';
import '../../../../core/services/auth_session_manager.dart';
import '../../../../core/utils/api_exception.dart';
import '../../models/auth_model.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  AuthSessionManager get _session => Get.find<AuthSessionManager>();

  String _getAuthHeader() {
    final token = _session.token ?? '';
    return 'Bearer $token';
  }

  /// Send OTP via phone number
  /// Matches backend: POST /api/auth/send-otp { phone: "9876543210" }
  Future<Map<String, dynamic>> sendOtp(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/send-otp',
        data: {'phone': phone},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Verify OTP - THE single entry point for both new and returning users
  /// Matches backend: POST /api/auth/otp-verify { phone: "9876543210", otp: "123456" }
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/otp-verify',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth = AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userEmail: auth.user.email,
          userAvatar: auth.user.profileImage ?? '',
          userPhone: phone,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'OTP verification failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException.unauthorized();
      }
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Resend OTP
  /// Matches backend: POST /api/auth/resend-otp { phone: "9876543210" }
  Future<Map<String, dynamic>> resendOtp(String phone) async {
    try {
      final response = await _dio.post(
        '/auth/resend-otp',
        data: {'phone': phone},
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Register/Complete profile after OTP
  /// Matches backend: POST /api/auth/register { phone, name, gender?, dob? }
  Future<AuthResponse> register({
    required String phone,
    required String name,
    String? gender,
    DateTime? dob,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          'phone': phone,
          'name': name,
          if (gender != null) 'gender': gender,
          if (dob != null) 'dob': dob.toIso8601String(),
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth = AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userPhone: phone,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'Registration failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Login with phone + otp for existing user
  /// Matches backend: POST /api/auth/login { phone, otp }
  Future<AuthResponse> login({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        final auth = AuthResponse.fromBackendJson(data);
        await _session.saveSession(
          token: auth.token,
          userId: auth.user.id,
          userName: auth.user.username,
          userPhone: phone,
        );
        return auth;
      }
      throw ApiException(message: data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw ApiException.unauthorized();
      }
      if (e.response?.statusCode == 404) {
        throw ApiException(message: 'User not found. Please sign up first.');
      }
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Refresh token
  /// Matches backend: POST /api/auth/refresh-token { refreshToken }
  Future<String> refreshToken(String refreshToken) async {
    try {
      final response = await _dio.post(
        '/auth/refresh-token',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data']['token'] as String;
      }
      throw ApiException(message: 'Token refresh failed');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Logout
  /// Matches backend: POST /api/auth/logout
  Future<void> logout() async {
    try {
      final token = _session.token;
      if (token != null && token.isNotEmpty) {
        await _dio.post(
          '/auth/logout',
          options: Options(headers: {
            'Authorization': 'Bearer $token',
          }),
        );
      }
    } on DioException catch (e) {
      // Logout errors are non-fatal
    } finally {
      await _session.clearSession();
    }
  }

  /// Get current user from backend
  /// Matches backend: GET /api/auth/me
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(
        '/auth/me',
        options: Options(headers: {
          'Authorization': _getAuthHeader(),
        }),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return User.fromBackendJson(data['data']);
      }
      throw ApiException(message: 'Failed to fetch user');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e.response?.data ?? {'message': e.message});
    }
  }

  /// Convenience redirect to session manager
  Future<void> saveToken(String token) => _session.saveSession(token: token);
  String? getToken() => _session.token;
  void clearToken() => _session.clearSession();
  bool isLoggedIn() => _session.hasToken();
}