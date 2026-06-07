// Root stub - the real wallet screen lives in /lib/modules/wallet/views/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'wallet_controller.dart';
import 'withdrawal_screen.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});
  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Wallet'), centerTitle: true, elevation: 0),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final w = controller.wallet.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.amber.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Balance', style: TextStyle(fontSize: 14, color: Colors.black54)),
                      const SizedBox(height: 8),
                      Text('${w?.coins ?? 0} Coins',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                      Text('${w?.diamonds ?? 0} Diamonds', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Get.to(() => WithdrawalScreen()),
                      icon: const Icon(Icons.account_balance_wallet),
                      label: const Text('Withdraw'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => controller.loadRechargePackages(),
                      icon: const Icon(Icons.add_circle),
                      label: const Text('Recharge'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
