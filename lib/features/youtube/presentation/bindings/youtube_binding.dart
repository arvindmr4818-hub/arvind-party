import 'package:get/get.dart';
import '../controllers/youtube_controller.dart';

class YouTubeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<YouTubeController>(() => YouTubeController(isHost: true));
  }
}