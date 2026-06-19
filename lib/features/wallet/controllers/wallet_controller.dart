import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/wallet_model.dart';
import '../repositories/wallet_repository.dart';

class WalletController extends GetxController {
  final WalletRepository _repo = WalletRepository();

  final balance = Rxn<WalletBalance>();
  final packages = <RechargePackage>[].obs;
  final withdrawMethods = <WithdrawMethod>[].obs;
  final transactions = <TransactionModel>[].obs;
  final isLoading = false.obs;
  final selectedPackage = Rxn<RechargePackage>();
  final selectedPaymentMethod = Rxn<String>();
  final isProcessingRecharge = false.obs;
  final selectedWithdrawMethod = Rxn<String>();
  final withdrawAmountController = TextEditingController();
  final accountDetailsController = TextEditingController();
  final isProcessingWithdraw = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([_repo.getBalance(), _repo.getRechargePackages(), _repo.getWithdrawMethods(), _repo.getTransactions()]);
      balance.value = results[0] as WalletBalance;
      packages.assignAll(results[1] as List<RechargePackage>);
      withdrawMethods.assignAll(results[2] as List<WithdrawMethod>);
      transactions.assignAll(results[3] as List<TransactionModel>);
    } catch (e) { Get.snackbar('Error', 'Failed to load wallet data'); }
    finally { isLoading.value = false; }
  }

  Future<void> processRecharge() async {
    if (selectedPackage.value == null) { Get.snackbar('Error', 'Please select a package'); return; }
    if (selectedPaymentMethod.value == null) { Get.snackbar('Error', 'Please select a payment method'); return; }
    isProcessingRecharge.value = true;
    try {
      await _repo.recharge(selectedPackage.value!.id, selectedPaymentMethod.value!);
      final pkg = selectedPackage.value!;
      balance.value = balance.value!.copyWith(
        coins: balance.value!.coins + pkg.coins,
        diamonds: balance.value!.diamonds + pkg.diamonds,
        beans: balance.value!.beans + pkg.beans,
      );
      Get.snackbar('Success', 'Recharge completed!');
      transactions.insert(0, TransactionModel(id: 'recharge_${DateTime.now().millisecondsSinceEpoch}', type: TransactionType.recharge, currency: CurrencyType.coins, amount: selectedPackage.value!.coins, description: 'Recharge: ${selectedPackage.value!.name}', status: TransactionStatus.completed, createdAt: DateTime.now()));
      resetRecharge();
    } catch (e) { Get.snackbar('Error', 'Recharge failed'); }
    finally { isProcessingRecharge.value = false; }
  }

  void resetRecharge() { selectedPackage.value = null; selectedPaymentMethod.value = null; }

  Future<void> processWithdraw() async {
    final amountText = withdrawAmountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    final account = accountDetailsController.text.trim();
    if (selectedWithdrawMethod.value == null) { Get.snackbar('Error', 'Please select a withdrawal method'); return; }
    final method = withdrawMethods.firstWhereOrNull((m) => m.id == selectedWithdrawMethod.value);
    if (amount < (method?.minAmount ?? 0)) { Get.snackbar('Error', 'Minimum withdrawal is \$${method?.minAmount}'); return; }
    if (account.isEmpty) { Get.snackbar('Error', 'Please enter account details'); return; }
    isProcessingWithdraw.value = true;
    try {
      await _repo.withdraw(selectedWithdrawMethod.value!, amount, account);
      Get.snackbar('Success', 'Withdrawal request submitted!');
      transactions.insert(0, TransactionModel(id: 'withdraw_${DateTime.now().millisecondsSinceEpoch}', type: TransactionType.withdraw, currency: CurrencyType.coins, amount: -(amount.toInt() * 100), description: 'Withdraw to ${method?.name}', status: TransactionStatus.pending, createdAt: DateTime.now()));
      withdrawAmountController.clear();
      accountDetailsController.clear();
      selectedWithdrawMethod.value = null;
    } catch (e) { Get.snackbar('Error', 'Withdrawal failed'); }
    finally { isProcessingWithdraw.value = false; }
  }

  @override
  void onClose() {
    withdrawAmountController.dispose();
    accountDetailsController.dispose();
    super.onClose();
  }
}