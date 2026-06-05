import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'draw_prize_model.dart';
import 'dart:math';

class LuckyDrawController extends GetxController {
  final isSpinning = false.obs;
  final prizes = <DrawPrizeModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Dummy items
    prizes.assignAll([
      DrawPrizeModel(id: 'p1', name: '100 Diamonds', icon: '💎'),
      DrawPrizeModel(id: 'p2', name: 'VIP 1 Day', icon: '👑'),
      DrawPrizeModel(id: 'p3', name: 'Try Again', icon: '😢'),
      DrawPrizeModel(id: 'p4', name: 'Rose Gift', icon: '🌹'),
      DrawPrizeModel(id: 'p5', name: '500 Coins', icon: '🪙'),
      DrawPrizeModel(id: 'p6', name: 'Magic Frame', icon: '🖼️'),
    ]);
  }

  void spinWheel(int times) async {
    if (isSpinning.value) return;

    isSpinning.value = true;
    // TODO: Deduct diamonds (e.g., 20 diamonds per spin) via API

    // Fake spinning delay
    await Future.delayed(const Duration(seconds: 3));
    isSpinning.value = false;

    // Fake result
    final result = prizes[Random().nextInt(prizes.length)];
    Get.defaultDialog(
        title: 'Congratulations!',
        middleText: 'You won:\n${result.icon} ${result.name}',
        backgroundColor: Colors.white);
  }
}
