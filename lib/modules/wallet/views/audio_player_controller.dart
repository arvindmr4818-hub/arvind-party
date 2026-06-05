import 'package:get/get.dart';
import '../models/song_model.dart';

class AudioPlayerController extends GetxController {
  final isPlaying = false.obs;
  final currentSong = Rxn<SongModel>();
  final playlist = <SongModel>[].obs;

  // TODO: Add audioplayers package AudioPlayer instance here

  @override
  void onInit() {
    super.onInit();
    _loadPlaylist();
  }

  void _loadPlaylist() {
    playlist.assignAll([
      SongModel(id: 's1', title: 'Lofi Chill Beats', artist: 'DJ Arvind'),
      SongModel(id: 's2', title: 'Party Anthem Mix', artist: 'Unknown'),
      SongModel(id: 's3', title: 'Acoustic Guitar', artist: 'Relaxation'),
    ]);
    if (playlist.isNotEmpty) {
      currentSong.value = playlist.first;
    }
  }

  void togglePlay() {
    isPlaying.value = !isPlaying.value;
    // TODO: Call real audioplayers package methods -> audioPlayer.play() or audioPlayer.pause()
  }

  void nextSong() {
    if (playlist.isEmpty) return;
    final currentIndex =
        playlist.indexWhere((s) => s.id == currentSong.value?.id);
    if (currentIndex != -1 && currentIndex < playlist.length - 1) {
      currentSong.value = playlist[currentIndex + 1];
    } else {
      currentSong.value = playlist.first; // Loop back to start
    }
  }
}
