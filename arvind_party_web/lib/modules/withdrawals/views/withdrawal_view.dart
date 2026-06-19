import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/withdrawal_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class WithdrawalView extends GetView<WithdrawalController> {
  const WithdrawalView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Withdrawal Requests',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadWithdrawals(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.withdrawals.isEmpty) {
          return const Center(
            child: Text('No withdrawal requests', style: TextStyle(color: WebTheme.textSecondary)),
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
                  DataColumn(label: Text('Amount')),
                  DataColumn(label: Text('Method')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.withdrawals.map((w) {
                  final id = w['id']?.toString() ?? '';
                  final status = w['status']?.toString() ?? 'pending';
                  final isPending = status == 'pending';
                  return DataRow(cells: [
                    DataCell(Text(w['username']?.toString() ?? w['uid']?.toString() ?? 'N/A')),
                    DataCell(Text(w['amount']?.toString() ?? '0')),
                    DataCell(Text(w['method']?.toString() ?? 'N/A')),
                    DataCell(_statusBadge(status)),
                    DataCell(Text(w['created_at']?.toString() ?? '')),
                    DataCell(isPending ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.approveWithdrawal(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebTheme.successGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showRejectDialog(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebTheme.errorRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('Reject'),
                        ),
                      ],
                    ) : Text(status.toUpperCase())),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'approved' ? WebTheme.successGreen
        : status == 'rejected' ? WebTheme.errorRed
        : WebTheme.warningAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _showRejectDialog(String id) {
    final reasonCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Reject Withdrawal'),
      content: TextField(
        controller: reasonCtrl,
        decoration: const InputDecoration(labelText: 'Reason', hintText: 'Optional reason for rejection'),
        maxLines: 3,
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.rejectWithdrawal(id, reasonCtrl.text.trim());
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white),
          child: const Text('Reject'),
        ),
      ],
    ));
  }
}