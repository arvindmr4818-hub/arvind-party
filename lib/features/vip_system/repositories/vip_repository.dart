// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/repositories/vip_repository.dart
// ARVIND PARTY - VIP REPOSITORY
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import '../../../core/constants/env_config.dart';
import '../models/vip_model.dart';

class VIPRepository {
  final Dio _dio = Dio();
  final String baseUrl = EnvConfig.plainApiBaseUrl;

  Future<List<VIPTier>> getVIPTiers() async {
    try {
      final response = await _dio.get('$baseUrl/vip/tiers');
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true) {
        final tiers = (data['data'] as List)
            .map((tier) => VIPTier.fromJson(tier as Map<String, dynamic>))
            .toList();
        return tiers;
      }
      throw Exception('Failed to fetch tiers');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<UserVIPStatus> getUserVIPStatus(String token) async {
    try {
      final response = await _dio.get(
        '$baseUrl/vip/status',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return UserVIPStatus.fromJson(data['data']);
      }
      throw Exception('Failed to fetch status');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> purchaseVIP(
    String token,
    String vipTierId,
  ) async {
    try {
      final response = await _dio.post(
        '$baseUrl/vip/purchase',
        data: {'vipTierId': vipTierId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      
      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data;
      }
      throw Exception('Purchase failed');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> activateVIP(String token, String vipTierId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/vip/activate',
        data: {'vipTierId': vipTierId},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      
      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception('Activation failed');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }
}