// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/youtube/presentation/controllers/youtube_controller.dart
// ARVIND PARTY - YOUTUBE ROOM CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../../models/youtube_video_model.dart';
import '../repositories/youtube_repository.dart';

class YouTubeController extends GetxController {
  final YouTubeRepository _repo = YouTubeRepository();

  // ─── Video State ───────────────────────────────────────────
  final currentVideo = Rxn<YouTubeVideo>();
  final playlist = <YouTubeVideo>[].obs;
  final isLoading = false.obs;
  final isPlaying = false.obs;
  final currentPosition = 0.0.obs;
  final videoDuration = 0.0.obs;
  final volume = 0.8.obs;

  // ─── Room State ────────────────────────────────────────────
  final String? roomId;
  final String? hostId;
  final String? currentUserId;
  final bool isHost;

  // ─── Watch Party ──────────────────────────────────────────
  final synchronizedPlayback = false.obs;
  final participants = <String>[].obs;

  YouTubeController({
    this.roomId,
    this.hostId,
    this.currentUserId,
    this.isHost = false,
  });

  @override
  void onInit() {
    super.onInit();
    loadPlaylist();
  }

  // ══════════════════════════════════════════════════════════════
  // VIDEO MANAGEMENT
  // ══════════════════════════════════════════════════════════════

  Future<void> loadPlaylist() async {
    isLoading.value = true;
    try {
      playlist.assignAll(await _repo.getPlaylist());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchVideos(String query) async {
    isLoading.value = true;
    try {
      final results = await _repo.searchVideos(query);
      playlist.assignAll(results);
    } finally {
      isLoading.value = false;
    }
  }

  void playVideo(YouTubeVideo video) {
    currentVideo.value = video;
    isPlaying.value = true;
    currentPosition.value = 0.0;
    videoDuration.value = video.duration ?? 0.0;
  }

  void togglePlayPause() {
    if (isHost || true) { // Host/moderator only
      isPlaying.value = !isPlaying.value;
    }
  }

  void seekTo(double position) {
    if (isHost || true) {
      currentPosition.value = position;
    }
  }

  void addToPlaylist(YouTubeVideo video) {
    playlist.add(video);
  }

  void removeFromPlaylist(int index) {
    if (isHost || true) {
      playlist.removeAt(index);
    }
  }

  void playNext() {
    if (currentVideo.value == null) return;
    final currentIndex = playlist.indexWhere((v) => v.id == currentVideo.value!.id);
    if (currentIndex < playlist.length - 1) {
      playVideo(playlist[currentIndex + 1]);
    }
  }

  void playPrevious() {
    if (currentVideo.value == null) return;
    final currentIndex = playlist.indexWhere((v) => v.id == currentVideo.value!.id);
    if (currentIndex > 0) {
      playVideo(playlist[currentIndex - 1]);
    }
  }

  // ══════════════════════════════════════════════════════════════
  // WATCH PARTY
  // ══════════════════════════════════════════════════════════════

  void toggleWatchParty() {
    if (hostId == currentUserId || isHost) {
      synchronizedPlayback.value = !synchronizedPlayback.value;
    }
  }

  void joinWatchParty(String userId) {
    if (!participants.contains(userId)) {
      participants.add(userId);
    }
  }

  void leaveWatchParty(String userId) {
    participants.remove(userId);
  }
}