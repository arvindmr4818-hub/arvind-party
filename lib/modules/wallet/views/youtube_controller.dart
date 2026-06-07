// lib/modules/wallet/views/youtube_controller.dart
import 'package:get/get.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/youtube_video_model.dart';

class YoutubeController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final isLoading = false.obs;
  final videos = <YoutubeVideoModel>[].obs;
  final selectedCategory = 'trending'.obs;
  final categories = <String>['trending', 'music', 'comedy', 'live', 'gaming', 'dance'];

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  Future<void> loadVideos() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/youtube/videos', query: {'category': selectedCategory.value});
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => YoutubeVideoModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        videos.assignAll(list);
      } else {
        videos.assignAll(_demoVideos());
      }
    } catch (_) {
      videos.assignAll(_demoVideos());
    } finally {
      isLoading.value = false;
    }
  }

  List<YoutubeVideoModel> _demoVideos() {
    return [
      YoutubeVideoModel(id: 'v1', title: 'Live Party Highlights', channelTitle: 'Arvind Party', thumbnailUrl: 'https://picsum.photos/seed/yt1/640/360', videoUrl: '', duration: 320, views: 15000),
      YoutubeVideoModel(id: 'v2', title: 'Top 10 Hosts This Week', channelTitle: 'Arvind Party', thumbnailUrl: 'https://picsum.photos/seed/yt2/640/360', videoUrl: '', duration: 540, views: 25000),
      YoutubeVideoModel(id: 'v3', title: 'PK Battle Compilation', channelTitle: 'Arvind Party', thumbnailUrl: 'https://picsum.photos/seed/yt3/640/360', videoUrl: '', duration: 280, views: 10000),
    ];
  }

  void selectCategory(String c) {
    selectedCategory.value = c;
    loadVideos();
  }

  Future<void> playVideo(YoutubeVideoModel video) async {
    try {
      await _api.post('/youtube/play', body: {'videoId': video.id});
    } catch (_) {}
  }
}
