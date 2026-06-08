// lib/core/network/games_binding.dart
import 'package:get/get.dart';
import '../../modules/wallet/controllers/mini_games_controller.dart';

class GamesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiniGamesController>(() => MiniGamesController());
  }
}
