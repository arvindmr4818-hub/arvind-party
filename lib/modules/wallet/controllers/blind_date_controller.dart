import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/blind_date_model.dart';
import '../../auth/views/api_service.dart';

class BlindDateController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final isSearching = false.obs;
  final currentMatch = Rxn<BlindDateMatch>();

  void startSearch() async {
    if (isSearching.value) return;

    isSearching.value = true;
    currentMatch.value = null;

    try {
      var response = await _apiService.post('matchmaking/search', {});

      if (response.statusCode == 200 && response.data['match'] != null) {
        var matchData = response.data['match'];
        currentMatch.value = BlindDateMatch(
          userId: matchData['userId'] ?? '',
          name: matchData['name'] ?? 'Unknown',
          avatar: matchData['avatar'] ?? '',
          age: matchData['age'] ?? 18,
          gender: matchData['gender'] ?? 'Unknown',
        );
        Get.snackbar('Match Found! 🎉',
            'Connecting you to ${currentMatch.value!.name}...',
            backgroundColor: Colors.pinkAccent, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to connect to matchmaking server.',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isSearching.value = false;
    }
  }

  void stopSearch() async {
    isSearching.value = false;
    try {
      await _apiService.post('matchmaking/stop', {});
    } catch (e) {
      // Silently handle leave queue errors
    }
    Get.snackbar('Search Stopped', 'You have left the matchmaking queue.',
        backgroundColor: Colors.black54, colorText: Colors.white);
  }
}
