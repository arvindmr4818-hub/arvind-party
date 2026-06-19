import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/web_theme.dart';
import '../../../core/network/admin_api.dart';

class CoinGenerationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final uidController = TextEditingController();
  final amountController = TextEditingController();
  final reasonController = TextEditingController();
  final isSubmitting = false.obs;

  @override
  void onClose() {
    uidController.dispose();
    amountController.dispose();
    reasonController.dispose();
    super.onClose();
  }

  Future<void> handleSubmit() async {
    if (!formKey.currentState!.validate()) return;

    isSubmitting.value = true;
    try {
      await AdminApi.to.generateCoins(
        uidController.text.trim(),
        int.parse(amountController.text.trim()),
        reasonController.text.trim().isNotEmpty
            ? reasonController.text.trim()
            : 'Admin coin generation',
      );
      Get.snackbar(
        'Success',
        'Coins generated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: WebTheme.successGreen,
        colorText: Colors.white,
      );
      uidController.clear();
      amountController.clear();
      reasonController.clear();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate coins',
        snackPosition: SnackPosition.TOP,
        backgroundColor: WebTheme.errorRed,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}