import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/pk_battle_model.dart';

class PkBattleController extends GetxController {
  final activeBattle = Rxn<PkBattleModel>();
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startDummyBattle() {
    activeBattle.value = PkBattleModel(
      battleId: 'pk_123',
      host1Id: 'host_1',
      host1Name: 'Arvind',
      host1Avatar: 'https://picsum.photos/seed/h1/100',
      host2Id: 'host_2',
      host2Name: 'Rival',
      host2Avatar: 'https://picsum.photos/seed/h2/100',
      remainingSeconds: 180, // 3 mins
    );
    _startTimer();
    Get.snackbar('⚔️ PK Started',
        'The battle has begun! Send gifts to support your host.',
        backgroundColor: Colors.orangeAccent, colorText: Colors.white);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (activeBattle.value != null &&
          activeBattle.value!.remainingSeconds > 0) {
        activeBattle.value = activeBattle.value!.copyWith(
          remainingSeconds: activeBattle.value!.remainingSeconds - 1,
          // Simulate random scoring for demo
          host1Score: activeBattle.value!.host1Score +
              (DateTime.now().second % 3 == 0 ? 10 : 0),
          host2Score: activeBattle.value!.host2Score +
              (DateTime.now().second % 4 == 0 ? 15 : 0),
        );
      } else {
        endBattle();
      }
    });
  }

  void sendGiftToHost(int hostNumber, int giftValue) {
    // TODO: Connect with Socket / Backend to register gift in PK
    if (activeBattle.value == null || !activeBattle.value!.isActive) return;

    if (hostNumber == 1) {
      activeBattle.value = activeBattle.value!
          .copyWith(host1Score: activeBattle.value!.host1Score + giftValue);
    } else {
      activeBattle.value = activeBattle.value!
          .copyWith(host2Score: activeBattle.value!.host2Score + giftValue);
    }
  }

  void endBattle() {
    _timer?.cancel();
    if (activeBattle.value != null) {
      activeBattle.value =
          activeBattle.value!.copyWith(isActive: false, remainingSeconds: 0);
      Get.snackbar('🏁 PK Ended', 'The battle is over!',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}
