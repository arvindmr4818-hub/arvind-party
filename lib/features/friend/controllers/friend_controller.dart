import 'package:get/get.dart';
import '../models/friend_model.dart';
import '../repositories/friend_repository.dart';

class FriendController extends GetxController {
  final FriendRepository _repo = FriendRepository();

  final friends = <FriendModel>[].obs;
  final followers = <FriendModel>[].obs;
  final following = <FriendModel>[].obs;
  final mutualFriends = <FriendModel>[].obs;
  final incomingRequests = <FriendRequestModel>[].obs;
  final outgoingRequests = <FriendRequestModel>[].obs;

  final isLoading = false.obs;
  final selectedUserId = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadAllFriendData();
  }

  Future<void> loadAllFriendData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repo.getFriends(),
        _repo.getFollowers(),
        _repo.getFollowing(),
        _repo.getIncomingRequests(),
        _repo.getOutgoingRequests(),
      ]);
      friends.assignAll(results[0] as List<FriendModel>);
      followers.assignAll(results[1] as List<FriendModel>);
      following.assignAll(results[2] as List<FriendModel>);
      incomingRequests.assignAll(results[3] as List<FriendRequestModel>);
      outgoingRequests.assignAll(results[4] as List<FriendRequestModel>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load friend data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendRequest(String userId) async {
    try {
      await _repo.sendFriendRequest(userId);
      final dummy = FriendRequestModel(
        id: 'temp_out_$userId',
        senderId: 'me',
        senderName: 'Me',
        createdAt: DateTime.now(),
      );
      outgoingRequests.add(dummy);
      Get.snackbar('Sent', 'Friend request sent!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send request');
    }
  }

  Future<void> acceptRequest(String requestId, String senderId) async {
    try {
      await _repo.acceptFriendRequest(requestId);
      incomingRequests.removeWhere((r) => r.id == requestId);
      final senderName = incomingRequests.firstWhereOrNull((r) => r.senderId == senderId)?.senderName ?? 'Friend';
      friends.add(FriendModel(id: senderId, username: senderName, status: FriendStatus.friends, isOnline: true));
      Get.snackbar('Accepted', 'Friend request accepted!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to accept request');
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _repo.rejectFriendRequest(requestId);
      incomingRequests.removeWhere((r) => r.id == requestId);
      Get.snackbar('Rejected', 'Friend request rejected');
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject request');
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await _repo.followUser(userId);
      final existing = following.firstWhereOrNull((f) => f.id == userId);
      if (existing == null) {
        following.add(FriendModel(id: userId, username: 'User $userId', status: FriendStatus.following));
      }
      Get.snackbar('Followed', 'You are now following this user');
    } catch (e) {
      Get.snackbar('Error', 'Failed to follow');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await _repo.unfollowUser(userId);
      following.removeWhere((f) => f.id == userId);
      Get.snackbar('Unfollowed', 'You have unfollowed this user');
    } catch (e) {
      Get.snackbar('Error', 'Failed to unfollow');
    }
  }

  Future<void> removeFriend(String userId) async {
    try {
      await _repo.removeFriend(userId);
      friends.removeWhere((f) => f.id == userId);
      Get.snackbar('Removed', 'Friend removed from list');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove friend');
    }
  }

  Future<void> loadMutualFriends(String userId) async {
    selectedUserId.value = userId;
    try {
      mutualFriends.assignAll(await _repo.getMutualFriends(userId));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load mutual friends');
    }
  }

  void clearMutualFriends() => mutualFriends.clear();
}