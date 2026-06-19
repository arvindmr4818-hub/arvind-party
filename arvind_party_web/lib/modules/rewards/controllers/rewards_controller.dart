import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/web_theme.dart';
import '../../../core/network/admin_api.dart';

class RewardsController extends GetxController {
  // Coin Control
  final coinUidCtrl = TextEditingController();
  final coinAmountCtrl = TextEditingController();
  final coinReasonCtrl = TextEditingController();
  final isGeneratingCoins = false.obs;
  final isDeductingCoins = false.obs;

  // Reward Sending
  final rewardUidCtrl = TextEditingController();
  final selectedRewardType = 'VIP'.obs;
  final rewardQuantityCtrl = TextEditingController(text: '1');
  final isSendingReward = false.obs;

  @override
  void onClose() {
    coinUidCtrl.dispose();
    coinAmountCtrl.dispose();
    coinReasonCtrl.dispose();
    rewardUidCtrl.dispose();
    rewardQuantityCtrl.dispose();
    super.onClose();
  }

  Future<void> generateCoins() async {
    if (coinUidCtrl.text.trim().isEmpty ||
        coinAmountCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all required fields',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.errorRed,
          colorText: Colors.white);
      return;
    }

    isGeneratingCoins.value = true;
    try {
      await AdminApi.to.generateCoins(
        coinUidCtrl.text.trim(),
        int.parse(coinAmountCtrl.text.trim()),
        coinReasonCtrl.text.trim().isNotEmpty
            ? coinReasonCtrl.text.trim()
            : 'Manual generation',
      );
      Get.snackbar('Success', 'Coins generated successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.successGreen,
          colorText: Colors.white);
      coinUidCtrl.clear();
      coinAmountCtrl.clear();
      coinReasonCtrl.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate coins',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.errorRed,
          colorText: Colors.white);
    } finally {
      isGeneratingCoins.value = false;
    }
  }

  Future<void> deductCoins() async {
    if (coinUidCtrl.text.trim().isEmpty ||
        coinAmountCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please fill all required fields',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.errorRed,
          colorText: Colors.white);
      return;
    }

    isDeductingCoins.value = true;
    try {
      await AdminApi.to.deductCoins(
        coinUidCtrl.text.trim(),
        int.parse(coinAmountCtrl.text.trim()),
        coinReasonCtrl.text.trim().isNotEmpty
            ? coinReasonCtrl.text.trim()
            : 'Manual deduction',
      );
      Get.snackbar('Success', 'Coins deducted successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.successGreen,
          colorText: Colors.white);
      coinUidCtrl.clear();
      coinAmountCtrl.clear();
      coinReasonCtrl.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to deduct coins',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.errorRed,
          colorText: Colors.white);
    } finally {
      isDeductingCoins.value = false;
    }
  }

  Future<void> sendReward() async {
    if (rewardUidCtrl.text.trim().isEmpty) {
      Get.snackbar('Validation Error', 'Please enter a UID',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.errorRed,
          colorText: Colors.white);
      return;
    }

    isSendingReward.value = true;
    try {
      await AdminApi.to.sendReward(
        uid: rewardUidCtrl.text.trim(),
        rewardType: selectedRewardType.value,
        quantity: int.tryParse(rewardQuantityCtrl.text.trim()) ?? 1,
      );
      Get.snackbar('Success', 'Reward sent successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.successGreen,
          colorText: Colors.white);
      rewardUidCtrl.clear();
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reward',
          snackPosition: SnackPosition.TOP,
          backgroundColor: WebTheme.errorRed,
          colorText: Colors.white);
    } finally {
      isSendingReward.value = false;
    }
  }
}