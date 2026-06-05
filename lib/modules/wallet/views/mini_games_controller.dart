import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'mini_game_model.dart';

class MiniGamesController extends GetxController {
  final games = <MiniGameModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadGames();
  }

  void _loadGames() {
    // Placeholder data - Later fetch from Backend API
    games.assignAll([
      MiniGameModel(id: 'ludo', title: 'Ludo Pro', icon: '🎲'),
      MiniGameModel(id: 'teenpatti', title: 'Teen Patti', icon: '🃏'),
      MiniGameModel(id: 'roulette', title: 'Roulette', icon: '🎡'),
      MiniGameModel(id: 'slots', title: 'Fruit Slots', icon: '🎰'),
      MiniGameModel(id: 'carrom', title: 'Carrom', icon: '🎱'),
    ]);
  }

  void launchGame(MiniGameModel game) {
    Get.back(); // Close bottom sheet
    Get.snackbar('Game Launching',
        'Starting ${game.title}... (Waiting for game engine integration)',
        backgroundColor: Colors.deepPurpleAccent, colorText: Colors.white);
  }
}
