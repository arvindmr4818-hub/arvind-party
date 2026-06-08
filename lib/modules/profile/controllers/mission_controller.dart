import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../auth/views/api_service.dart';
import '../models/mission_model.dart';

class MissionController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  var missions = <MissionModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMissions();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> fetchMissions() async {
    try {
      isLoading(true);
      final response = await _apiService.get('users/missions');
      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['missions'] ?? [];
        missions.value = data.map((json) => MissionModel.fromJson(json)).toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load missions');
    } finally {
      isLoading(false);
    }
  }

  Future<void> claimReward(String missionId) async {
    try {
      final response = await _apiService.post('users/missions/claim', {'missionId': missionId});
      if (response.statusCode == 200 && response.data['success'] == true) {
        // Try to play sound (if missing, it silently skips)
        _audioPlayer.play(AssetSource('sounds/coin_clink.mp3')).catchError((_) => null);
        Get.snackbar('Mission Completed!', 'You received ${response.data['rewardCoins']} Coins!', backgroundColor: Colors.green, colorText: Colors.white);
        fetchMissions(); // Refresh to update progress UI
      }
    } catch (e) {}
  }
}