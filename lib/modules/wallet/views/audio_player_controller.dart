import 'package:get/get.dart';
import '../../../shared/models/song_model.dart';

class AudioPlayerController extends GetxController {
  final isPlaying = false.obs;
  final currentSong = Rxn<SongModel>();
  final playlist = <SongModel>[].obs;
  final currentPosition = 0.obs;
  final totalDuration = 0.obs;
  final volume = 0.8.obs;
  final isShuffleOn = false.obs;
  final repeatMode = 0.obs; // 0=off, 1=all, 2=one

  @override
  void onInit() {
    super.onInit();
    _loadPlaylist();
  }

  void _loadPlaylist() {
    playlist.assignAll([
      SongModel(id: 's1', title: 'Lofi Chill Beats', artist: 'DJ Arvind', coverUrl: '', audioUrl: '', duration: 180),
      SongModel(id: 's2', title: 'Party Anthem Mix', artist: 'Unknown', coverUrl: '', audioUrl: '', duration: 220),
      SongModel(id: 's3', title: 'Acoustic Guitar', artist: 'Relaxation', coverUrl: '', audioUrl: '', duration: 195),
    ]);
    if (playlist.isNotEmpty) {
      currentSong.value = playlist.first;
    }
  }

  void togglePlay() {
    isPlaying.value = !isPlaying.value;
  }

  void playSong(SongModel song) {
    currentSong.value = song;
    isPlaying.value = true;
  }

  void nextSong() {
    if (playlist.isEmpty) return;
    if (isShuffleOn.value) {
      final random = (playlist.length * DateTime.now().millisecondsSinceEpoch) % playlist.length;
      currentSong.value = playlist[random];
      return;
    }
    final currentIndex = playlist.indexWhere((s) => s.id == currentSong.value?.id);
    if (currentIndex != -1 && currentIndex < playlist.length - 1) {
      currentSong.value = playlist[currentIndex + 1];
    } else {
      currentSong.value = playlist.first;
    }
  }

  void previousSong() {
    if (playlist.isEmpty) return;
    final currentIndex = playlist.indexWhere((s) => s.id == currentSong.value?.id);
    if (currentIndex > 0) {
      currentSong.value = playlist[currentIndex - 1];
    } else {
      currentSong.value = playlist.last;
    }
  }

  void toggleShuffle() {
    isShuffleOn.value = !isShuffleOn.value;
  }

  void cycleRepeat() {
    repeatMode.value = (repeatMode.value + 1) % 3;
  }

  void seekTo(int seconds) {
    currentPosition.value = seconds;
  }

  void setVolume(double v) {
    volume.value = v.clamp(0.0, 1.0);
  }
}
