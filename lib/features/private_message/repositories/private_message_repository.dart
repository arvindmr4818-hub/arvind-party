import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/constants/env_config.dart';
import '../models/private_message_model.dart';

class PrivateMessageRepository {
  final Dio _dio = Dio();
  final storage = GetStorage();
  final String baseUrl = EnvConfig.plainApiBaseUrl;

  String _getAuthHeader() {
    final token = storage.read('token') ?? '';
    return 'Bearer $token';
  }

  Future<List<PrivateChatUser>> getPrivateChats({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/messages/private/chats',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((chat) => PrivateChatUser.fromJson(chat as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch chats');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<List<PrivateMessage>> getPrivateMessages(
    String userId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/messages/private/$userId',
        queryParameters: {'page': page, 'limit': limit},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((msg) => PrivateMessage.fromJson(msg as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to fetch messages');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<PrivateMessage> sendMessage({
    required String recipientId,
    required String content,
    String messageType = 'text',
  }) async {
    try {
      final response = await _dio.post(
        '$baseUrl/messages/private/send',
        data: {
          'recipientId': recipientId,
          'content': content,
          'messageType': messageType,
        },
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return PrivateMessage.fromJson(data['data']);
      }
      throw Exception('Failed to send message');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<PrivateMessage> uploadMedia({
    required String recipientId,
    required String filePath,
    required String messageType, // image, video, voice, file
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'recipientId': recipientId,
        'messageType': messageType,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        '$baseUrl/messages/private/upload',
        data: formData,
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return PrivateMessage.fromJson(data['data']);
      }
      throw Exception('Upload failed');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> markAsRead(String messageId) async {
    try {
      await _dio.post(
        '$baseUrl/messages/private/$messageId/read',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _dio.post(
        '$baseUrl/messages/private/$userId/read-all',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _dio.delete(
        '$baseUrl/messages/private/$messageId',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await _dio.put(
        '$baseUrl/messages/private/$messageId',
        data: {'content': newContent},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<UserStatus> getUserStatus(String userId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/users/$userId/status',
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true) {
        return UserStatus.fromJson(data['data']);
      }
      throw Exception('Failed to fetch status');
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> setTypingStatus(String userId, bool isTyping) async {
    try {
      await _dio.post(
        '$baseUrl/messages/private/$userId/typing',
        data: {'isTyping': isTyping},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }

  Future<void> setOnlineStatus(bool isOnline) async {
    try {
      await _dio.post(
        '$baseUrl/users/status',
        data: {'isOnline': isOnline},
        options: Options(headers: {'Authorization': _getAuthHeader()}),
      );
    } on DioException catch (e) {
      throw Exception('API Error: ${e.message}');
    }
  }
}