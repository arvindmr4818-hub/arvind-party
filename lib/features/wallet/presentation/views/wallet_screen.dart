// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/wallet/presentation/views/wallet_screen.dart
// ARVIND PARTY - WALLET SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_model.dart';
import '../../widgets/currency_card.dart';
import '../../widgets/recharge_package_item.dart';
import '../../widgets/transaction_item.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WalletController());
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Obx(() {
        if (controller.isLoading.value && controller.balance.value == null) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle),
                    label: const Text('Recharge'),
                    onPressed: () => _showRechargeDialog(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 12)),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_circle_right),
                    label: const Text('Withdraw'),
                    onPressed: () => _showWithdrawDialog(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)),
                  )),
                ],
              ),
              const SizedBox(height: 20),
              if (controller.balance.value != null) ...[
                Row(children: [
                  Expanded(child: CurrencyCard(type: CurrencyType.coins, amount: controller.balance.value!.coins)),
                  const SizedBox(width: 12),
                  Expanded(child: CurrencyCard(type: CurrencyType.diamonds, amount: controller.balance.value!.diamonds)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: CurrencyCard(type: CurrencyType.beans, amount: controller.balance.value!.beans)),
                  const Spacer(),
                ]),
              ],
              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(onPressed: controller.loadAllData, child: const Text('Refresh')),
              ]),
              const Divider(),
              if (controller.transactions.isEmpty)
                const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey)))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: controller.transactions.length,
                  itemBuilder: (context, index) => TransactionItem(transaction: controller.transactions[index]),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  void _showRechargeDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Text('Recharge Wallet'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ...controller.packages.map((pkg) =>
            RechargePackageItem(package: pkg, isSelected: controller.selectedPackage.value?.id == pkg.id, onTap: () => controller.selectedPackage.value = pkg,),
          ),
          const SizedBox(height: 12),
          const Text('Select Payment Method', style: TextStyle(fontWeight: FontWeight.w600)),
          Obx(() => Row(children: [
            _payChip('PayPal', 'paypal', controller.selectedPaymentMethod.value == 'paypal'),
            _payChip('Card', 'card', controller.selectedPaymentMethod.value == 'card'),
            _payChip('GPay', 'gpay', controller.selectedPaymentMethod.value == 'gpay'),
          ])),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessingRecharge.value ? null : controller.processRecharge,
            child: controller.isProcessingRecharge.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Pay Now'),
          )),
        ]),
      ),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close'))],
    ));
  }

  Widget _payChip(String label, String value, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(label: Text(label), selected: selected, onSelected: (_) => controller.selectedPaymentMethod.value = value, selectedColor: Colors.blue.shade100),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    Get.dialog(AlertDialog(
      title: const Text('Withdraw Funds'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Select Method', style: TextStyle(fontWeight: FontWeight.w600)),
          Obx(() => Wrap(spacing: 8, children: controller.withdrawMethods.map((m) => FilterChip(label: Text(m.name), selected: controller.selectedWithdrawMethod.value == m.id, onSelected: (_) => controller.selectedWithdrawMethod.value = m.id)).toList())),
          const SizedBox(height: 12),
          TextField(controller: controller.withdrawAmountController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Amount (USD)', prefixText: '\$ ', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: controller.accountDetailsController, decoration: const InputDecoration(labelText: 'Account Details', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          Obx(() => ElevatedButton(
            onPressed: controller.isProcessingWithdraw.value ? null : controller.processWithdraw,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: controller.isProcessingWithdraw.value ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit'),
          )),
        ]),
      ),
      actions: [TextButton(onPressed: () => Get.back(), child: const Text('Close'))],
    ));
  }
}