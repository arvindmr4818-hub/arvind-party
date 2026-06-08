import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/youtube_video_model.dart';

class YoutubeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  // ── Reactive State Variables ───────────────────────────────────
  final isLoading = false.obs;
  final videos = <YoutubeVideoModel>[].obs;
  final selectedCategory = 'trending'.obs;
  
  // ✅ FIX 1: Added missing reactive currentVideo variable for screen rendering
  final currentVideo = Rxn<YoutubeVideoModel>();

  final categories = <String>['trending', 'music', 'comedy', 'live', 'gaming', 'dance'];

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  // 🌐 REAL TIME API: Fetch live videos catalog from server MongoDB
  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/youtube/videos', query: {'category': selectedCategory.value});
      
      if (response is Map && response['success'] == true) {
        final List<dynamic> serverData = response['data'] ?? [];
        final list = serverData
            .map((e) => YoutubeVideoModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        videos.assignAll(list);
      } else {
        videos.clear(); // Real empty state mapping frame
      }
    } catch (e) {
      debugPrint('Error loading media assets from backend: $e');
      videos.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String c) {
    selectedCategory.value = c;
    loadVideos();
  }

  // 🎬 REAL TIME API: Broadcast video synchronization command to the server
  Future<void> playVideo(YoutubeVideoModel video) async {
    try {
      // Set locally first for instant reactive response rendering
      currentVideo.value = video;

      // Node.js sync signal channel hit: router.post('/youtube/play', ...)
      await _api.post('/youtube/play', body: {'videoId': video.id});
    } catch (e) {
      debugPrint('Failed to transmit playback synchronization stream: $e');
    }
  }
}