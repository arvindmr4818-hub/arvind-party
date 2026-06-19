import 'package:dio/dio.dart';
import '../../../core/constants/env_config.dart';
import '../models/block_model.dart';

class BlockRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<BlockedUserModel>> getBlockedUsers() async {
    try {
      final response = await _dio.get('/block');
      return (response.data['data'] as List).map((e) => BlockedUserModel.fromJson(e)).toList();
    } catch (e) { return _mockBlockedUsers(); }
  }

  Future<List<MutedUserModel>> getMutedUsers() async {
    try {
      final response = await _dio.get('/mute');
      return (response.data['data'] as List).map((e) => MutedUserModel.fromJson(e)).toList();
    } catch (e) { return _mockMutedUsers(); }
  }

  Future<void> blockUser(String userId) async => await _dio.post('/block', data: {'targetUserId': userId});
  Future<void> unblockUser(String userId) async => await _dio.delete('/block/$userId');
  Future<void> muteUser(String userId, MuteDuration duration) async {
    int seconds;
    switch (duration) {
      case MuteDuration.fifteenMinutes: seconds = 15 * 60; break;
      case MuteDuration.oneHour: seconds = 60 * 60; break;
      case MuteDuration.sixHours: seconds = 6 * 60 * 60; break;
      case MuteDuration.oneDay: seconds = 24 * 60 * 60; break;
      case MuteDuration.oneWeek: seconds = 7 * 24 * 60 * 60; break;
      case MuteDuration.forever: seconds = -1; break;
    }
    await _dio.post('/mute', data: {'targetUserId': userId, 'durationSeconds': seconds});
  }
  Future<void> unmuteUser(String userId) async => await _dio.delete('/mute/$userId');

  List<BlockedUserModel> _mockBlockedUsers() => List.generate(3, (i) => BlockedUserModel(
    userId: 'blocked_$i', username: 'Blocked User $i', avatarUrl: 'https://picsum.photos/seed/b$i/100',
    blockedAt: DateTime.now().subtract(Duration(days: i + 1)),
  ));

  List<MutedUserModel> _mockMutedUsers() => List.generate(2, (i) => MutedUserModel(
    userId: 'muted_$i', username: 'Muted User $i', avatarUrl: 'https://picsum.photos/seed/m$i/100',
    mutedAt: DateTime.now().subtract(Duration(hours: i + 2)),
    mutedUntil: i == 0 ? DateTime.now().add(const Duration(days: 1)) : null,
  ));
}