import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';

class SocialController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  // --- State Variables ---
  var isLoading = false.obs;
  
  // Follow & Friends
  var followers = <Map<String, dynamic>>[].obs;
  var following = <Map<String, dynamic>>[].obs;
  var friends = <Map<String, dynamic>>[].obs; // Mutual follows

  // CP Relationship
  var currentCp = Rxn<Map<String, dynamic>>();
  var cpLevel = 0.obs;
  var cpRequests = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSocialData();
  }

  Future<void> fetchSocialData() async {
    isLoading(true);
    try {
      await Future.wait([
        fetchConnections(),
        fetchCpStatus(),
      ]);
    } finally {
      isLoading(false);
    }
  }

  // --- 👤 Follow & Friends System ---
  Future<void> fetchConnections() async {
    try {
      final response = await _apiService.get('social/connections');
      if (response != null && response['success'] == true) {
        followers.assignAll(List<Map<String, dynamic>>.from(response['data']['followers'] ?? []));
        following.assignAll(List<Map<String, dynamic>>.from(response['data']['following'] ?? []));
        friends.assignAll(List<Map<String, dynamic>>.from(response['data']['friends'] ?? [])); // Mutual
      }
    } catch (e) {
      print('Error fetching connections: $e');
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    try {
      final response = await _apiService.post('social/follow', body: {'targetUserId': targetUserId});
      if (response != null && response['success'] == true) {
        bool isNowFollowing = response['isFollowing'];
        Get.snackbar(
          'Success', 
          isNowFollowing ? 'You are now following this user.' : 'Unfollowed successfully.',
          backgroundColor: isNowFollowing ? Colors.green : Colors.orange,
          colorText: Colors.white,
        );
        fetchConnections(); // Refresh lists to update friends/followers locally
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update follow status.');
    }
  }

  // --- 💖 CP Relationship System ---
  Future<void> fetchCpStatus() async {
    try {
      final response = await _apiService.get('social/cp/status');
      if (response != null && response['success'] == true) {
        final data = response['data'];
        if (data['partner'] != null) {
          currentCp.value = Map<String, dynamic>.from(data['partner']);
          cpLevel.value = data['level'] ?? 1;
        } else {
          currentCp.value = null;
          cpRequests.assignAll(List<Map<String, dynamic>>.from(data['pendingRequests'] ?? []));
        }
      }
    } catch (e) {
      print('Error fetching CP status: $e');
    }
  }

  Future<void> sendCpRequest(String targetUserId) async {
    try {
      final response = await _apiService.post('social/cp/request', body: {'targetUserId': targetUserId});
      if (response != null && response['success'] == true) {
        Get.snackbar('Sent! 💖', 'CP request has been sent to the user!',
            backgroundColor: Colors.pinkAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Failed', 'Could not send CP request.');
    }
  }

  Future<void> respondToCpRequest(String requestId, bool accept) async {
    try {
      final response = await _apiService.post('social/cp/respond', body: {
        'requestId': requestId,
        'accept': accept
      });
      if (response != null && response['success'] == true) {
        Get.snackbar('Success', accept ? 'Congratulations on your new CP! 🎉' : 'Request declined.');
        fetchCpStatus(); // Refresh CP status
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to respond to CP request.');
    }
  }
}