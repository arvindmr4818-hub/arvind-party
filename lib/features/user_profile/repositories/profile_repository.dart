import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/env_config.dart';
import '../models/user_profile_model.dart';

class ProfileRepository {
  final Dio _dio = Dio();
  final storage = GetStorage();
  final String baseUrl = EnvConfig.plainApiBaseUrl;

  String _getAuthHeader() {
    final token = storage.read('token') ?? '';
    return 'Bearer $token';
  }

  Future<UserProfile> getMyProfile() async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/me',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return UserProfile.fromJson(data['data']);
      }
      throw Exception('Failed to fetch profile');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<UserProfile> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/$userId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return UserProfile.fromJson(data['data']);
      }
      throw Exception('Failed to fetch profile');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<UserProfile> updateProfile({
    String? nickname,
    String? bio,
    String? gender,
    String? country,
    String? language,
    DateTime? birthday,
    String? website,
    List<String>? interests,
    bool? isPrivate,
  }) async {
    try {
      final response = await _dio.put(
        '$baseUrl/profile/update',
        data: {
          'nickname': nickname,
          'bio': bio,
          'gender': gender,
          'country': country,
          'language': language,
          'birthday': birthday?.toIso8601String(),
          'website': website,
          'interests': interests,
          'isPrivate': isPrivate,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return UserProfile.fromJson(data['data']);
      }
      throw Exception('Profile update failed');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '$baseUrl/profile/avatar',
        data: formData,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data']['avatarUrl'] ?? '';
      }
      throw Exception('Avatar upload failed');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<String> uploadCoverImage(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'coverImage': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '$baseUrl/profile/cover',
        data: formData,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return data['data']['coverImageUrl'] ?? '';
      }
      throw Exception('Cover image upload failed');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> followUser(String userId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/profile/$userId/follow',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception('Follow failed');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/profile/$userId/unfollow',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] != true) {
        throw Exception('Unfollow failed');
      }
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> blockUser(String userId) async {
    try {
      await _dio.post(
        '$baseUrl/profile/$userId/block',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      await _dio.post(
        '$baseUrl/profile/$userId/unblock',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<List<UserProfile>> getFollowers(String userId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/$userId/followers',
        queryParameters: {'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((user) => UserProfile.fromJson(user as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch followers');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<List<UserProfile>> getFollowing(String userId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/$userId/following',
        queryParameters: {'page': page},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((user) => UserProfile.fromJson(user as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch following');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<ProfileStats> getProfileStats(String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/$userId/stats',
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return ProfileStats.fromJson(data['data']);
      }
      throw Exception('Failed to fetch stats');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<List<UserProfile>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '$baseUrl/profile/search',
        queryParameters: {'q': query},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((user) => UserProfile.fromJson(user as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Search failed');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> setPrivacyStatus(bool isPrivate) async {
    try {
      await _dio.put(
        '$baseUrl/profile/privacy',
        data: {'isPrivate': isPrivate},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }
}
