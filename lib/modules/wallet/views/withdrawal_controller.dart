import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/withdrawal_method_model.dart';

class WithdrawalController extends GetxController {
  final isLoading = false.obs;

  // Earning balance (e.g., Beans / Coins earned from gifts)
  final beansBalance = 0.obs;

  // Exchange rate: How many beans equal 1 USD? (e.g., 210 beans = 1 USD)
  final int beansPerUsd = 210;

  final withdrawalMethods = <WithdrawalMethod>[].obs;
  final selectedMethod = Rxn<WithdrawalMethod>();

  final amountController = TextEditingController();

  double get usdEquivalent => beansBalance.value / beansPerUsd;

  @override
  void onInit() {
    super.onInit();
    _loadWithdrawalData();
  }

  void _loadWithdrawalData() async {
    isLoading.value = true;

    // TODO: Replace with Real Backend API Call (e.g., apiService.getWithdrawalInfo())
    await Future.delayed(const Duration(milliseconds: 1000));

    // Dummy data for now
    beansBalance.value = 15450;

    withdrawalMethods.assignAll([
      WithdrawalMethod(
        id: 'payoneer',
        name: 'Payoneer',
        icon:
            'assets/images/payoneer.png', // Ensure this image exists later or use icons
        minWithdrawalUsd: 50.0,
        feePercentage: 1.5,
        processingTime: '1-3 Business Days',
      ),
      WithdrawalMethod(
        id: 'bank_transfer',
        name: 'Bank Transfer',
        icon: 'assets/images/bank.png',
        minWithdrawalUsd: 100.0,
        feePercentage: 2.0,
        processingTime: '3-5 Business Days',
      ),
      WithdrawalMethod(
        id: 'epay',
        name: 'Epay',
        icon: 'assets/images/epay.png',
        minWithdrawalUsd: 10.0,
        feePercentage: 1.0,
        processingTime: 'Instant',
      ),
    ]);

    if (withdrawalMethods.isNotEmpty) {
      selectedMethod.value = withdrawalMethods.first;
    }

    isLoading.value = false;
  }

  void selectMethod(WithdrawalMethod method) {
    selectedMethod.value = method;
  }

  void submitWithdrawal() {
    final amountStr = amountController.text.trim();
    if (amountStr.isEmpty) {
      Get.snackbar('Error', 'Please enter an amount to withdraw',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final amount = double.tryParse(amountStr) ?? 0.0;
    if (amount < (selectedMethod.value?.minWithdrawalUsd ?? 0)) {
      Get.snackbar('Error',
          'Minimum withdrawal for ${selectedMethod.value?.name} is \$${selectedMethod.value?.minWithdrawalUsd}',
          backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    // TODO: Send withdrawal request to real backend
    Get.snackbar('Success',
        'Withdrawal request for \$${amount.toStringAsFixed(2)} submitted successfully. It will be processed soon.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4));
  }
}
