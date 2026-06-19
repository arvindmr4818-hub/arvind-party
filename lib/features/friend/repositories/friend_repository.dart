import 'package:dio/dio.dart';
import '../../../core/constants/env_config.dart';
import '../models/friend_model.dart';

class FriendRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<FriendModel>> getFriends() async {
    try {
      final response = await _dio.get('/friends');
      return (response.data['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return _mockFriends(FriendStatus.friends); }
  }

  Future<List<FriendModel>> getFollowers() async {
    try {
      final response = await _dio.get('/friends/followers');
      return (response.data['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return _mockFollowers(); }
  }

  Future<List<FriendModel>> getFollowing() async {
    try {
      final response = await _dio.get('/friends/following');
      return (response.data['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return _mockFollowing(); }
  }

  Future<List<FriendModel>> getMutualFriends(String userId) async {
    try {
      final response = await _dio.get('/friends/mutual', queryParameters: {'userId': userId});
      return (response.data['data'] as List).map((e) => FriendModel.fromJson(e)).toList();
    } catch (e) { return _mockMutual(); }
  }

  Future<List<FriendRequestModel>> getIncomingRequests() async {
    try {
      final response = await _dio.get('/friends/requests/incoming');
      return (response.data['data'] as List).map((e) => FriendRequestModel.fromJson(e)).toList();
    } catch (e) { return _mockIncomingRequests(); }
  }

  Future<List<FriendRequestModel>> getOutgoingRequests() async {
    try {
      final response = await _dio.get('/friends/requests/outgoing');
      return (response.data['data'] as List).map((e) => FriendRequestModel.fromJson(e)).toList();
    } catch (e) { return _mockOutgoingRequests(); }
  }

  Future<void> sendFriendRequest(String userId) async => await _dio.post('/friends/request', data: {'userId': userId});
  Future<void> acceptFriendRequest(String requestId) async => await _dio.put('/friends/request/$requestId/accept');
  Future<void> rejectFriendRequest(String requestId) async => await _dio.delete('/friends/request/$requestId');
  Future<void> followUser(String userId) async => await _dio.post('/friends/follow', data: {'userId': userId});
  Future<void> unfollowUser(String userId) async => await _dio.delete('/friends/follow', data: {'userId': userId});
  Future<void> removeFriend(String userId) async => await _dio.delete('/friends/$userId');

  List<FriendModel> _mockFriends(FriendStatus status) => List.generate(8, (i) => FriendModel(
    id: 'f$i', username: 'Friend $i', avatarUrl: 'https://picsum.photos/seed/f$i/100',
    status: status, mutualFriendsCount: (i * 2) % 5, isOnline: i % 2 == 0,
  ));

  List<FriendModel> _mockFollowers() => List.generate(5, (i) => FriendModel(
    id: 'fol$i', username: 'Follower $i', avatarUrl: 'https://picsum.photos/seed/fol$i/100',
    status: FriendStatus.follower, isOnline: i % 3 == 0,
  ));

  List<FriendModel> _mockFollowing() => List.generate(6, (i) => FriendModel(
    id: 'folg$i', username: 'Following $i', avatarUrl: 'https://picsum.photos/seed/folg$i/100',
    status: FriendStatus.following, isOnline: i % 2 != 0,
  ));

  List<FriendModel> _mockMutual() => List.generate(3, (i) => FriendModel(
    id: 'mut$i', username: 'Mutual $i', avatarUrl: 'https://picsum.photos/seed/mut$i/100',
    status: FriendStatus.friends, mutualFriendsCount: (i + 1) * 2,
  ));

  List<FriendRequestModel> _mockIncomingRequests() => List.generate(3, (i) => FriendRequestModel(
    id: 'inr$i', senderId: 'sender$i', senderName: 'Incoming User $i',
    senderAvatar: 'https://picsum.photos/seed/inr$i/100', createdAt: DateTime.now().subtract(Duration(hours: i + 1)),
  ));

  List<FriendRequestModel> _mockOutgoingRequests() => List.generate(2, (i) => FriendRequestModel(
    id: 'outr$i', senderId: 'me$i', senderName: 'Me',
    senderAvatar: 'https://picsum.photos/seed/outr$i/100', createdAt: DateTime.now().subtract(Duration(days: i + 1)),
  ));
}