import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'blind_date_model.dart';

class BlindDateController extends GetxController {
  final isSearching = false.obs;
  final currentMatch = Rxn<BlindDateMatch>();

  void startSearch() async {
    if (isSearching.value) return;

    isSearching.value = true;
    currentMatch.value = null;

    // TODO: Connect with Real Socket/Backend for matchmaking queue
    // Fake delay to simulate radar search
    await Future.delayed(const Duration(seconds: 4));

    isSearching.value = false;

    // Fake Match Result
    currentMatch.value = BlindDateMatch(
      userId: 'user_99',
      name: 'Priya',
      avatar: 'https://picsum.photos/seed/priya/200',
      age: 22,
      gender: 'Female',
    );

    Get.snackbar(
        'Match Found! 🎉', 'Connecting you to ${currentMatch.value!.name}...',
        backgroundColor: Colors.pinkAccent, colorText: Colors.white);
  }

  void stopSearch() {
    isSearching.value = false;
    // TODO: Send leave queue event to backend
    Get.snackbar('Search Stopped', 'You have left the matchmaking queue.',
        backgroundColor: Colors.black54, colorText: Colors.white);
  }
}
