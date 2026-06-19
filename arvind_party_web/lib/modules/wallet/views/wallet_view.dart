import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Wallet Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadWallets(),
          tooltip: 'Refresh',
        ),
      ],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: WebTheme.cardDark,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by user...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => controller.loadWallets(search: value),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.wallets.isEmpty) {
                return const Center(
                  child: Text('No wallets found', style: TextStyle(color: WebTheme.textSecondary)),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Coins')),
                        DataColumn(label: Text('Diamonds')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.wallets.map((w) {
                        return DataRow(cells: [
                          DataCell(Text(w['username']?.toString() ?? w['uid']?.toString() ?? 'N/A')),
                          DataCell(Text(w['coins']?.toString() ?? '0')),
                          DataCell(Text(w['diamonds']?.toString() ?? '0')),
                          DataCell(Text(w['status']?.toString() ?? 'active')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _showAdjustDialog(w),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WebTheme.primaryOrange,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero,
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('Adjust'),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showAdjustDialog(Map<String, dynamic> wallet) {
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final userId = wallet['id']?.toString() ?? wallet['uid']?.toString() ?? '';

    Get.dialog(AlertDialog(
      title: const Text('Adjust Wallet'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: amountCtrl,
          decoration: const InputDecoration(labelText: 'Amount (+/-)', hintText: 'Use negative to deduct'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        TextField(
          controller: reasonCtrl,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final amount = int.tryParse(amountCtrl.text.trim()) ?? 0;
            if (amount != 0) {
              controller.adjustWallet(userId, amount, reasonCtrl.text.trim());
              Get.back();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ));
  }
}