import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recharge_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class RechargeView extends GetView<RechargeController> {
  const RechargeView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Recharge History',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadRecharges(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.recharges.isEmpty) {
          return const Center(
            child: Text('No recharges found', style: TextStyle(color: WebTheme.textSecondary)),
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
                ],
                rows: controller.recharges.map((r) {
                  return DataRow(cells: [
                    DataCell(Text(r['username']?.toString() ?? r['uid']?.toString() ?? 'N/A')),
                    DataCell(Text(r['amount']?.toString() ?? '0')),
                    DataCell(Text(r['method']?.toString() ?? 'N/A')),
                    DataCell(Text(r['status']?.toString() ?? 'completed')),
                    DataCell(Text(r['created_at']?.toString() ?? '')),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      }),
    );
  }
}