// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/lucky_draw/presentation/controllers/lucky_draw_controller.dart
// ARVIND PARTY - LUCKY DRAW CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class LuckyDrawController extends GetxController {
  final isLoading = false.obs;
  final isSpinning = false.obs;
  final prize = ''.obs;

  void spin() async {
    if (isSpinning.value) return;
    try {
      isSpinning.value = true;
      // TODO: Call lottery API
      await Future.delayed(const Duration(seconds: 3));
      final prizes = ['100 coins', '50 coins', 'Try Again', '200 coins', 'Diamond', '10 coins'];
      prize.value = prizes[DateTime.now().millisecond % prizes.length];
      Get.snackbar('Congratulations!', 'You won \${prize.value}');
    } catch (e) {
      Get.snackbar('Error', 'Spin failed');
    } finally {
      isSpinning.value = false;
    }
  }
}