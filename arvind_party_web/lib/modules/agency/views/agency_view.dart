import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class AgencyView extends GetView<AgencyController> {
  const AgencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Agency Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadAgencies(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.agencies.isEmpty) {
          return const Center(
            child: Text('No agencies found', style: TextStyle(color: WebTheme.textSecondary)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Agency Name')),
                  DataColumn(label: Text('Owner')),
                  DataColumn(label: Text('Members')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.agencies.map((a) {
                  final id = a['id']?.toString() ?? '';
                  final status = a['status']?.toString() ?? 'pending';
                  final isPending = status == 'pending';
                  return DataRow(cells: [
                    DataCell(Text(a['name']?.toString() ?? 'N/A')),
                    DataCell(Text(a['owner']?.toString() ?? 'N/A')),
                    DataCell(Text(a['members']?.toString() ?? '0')),
                    DataCell(_statusBadge(status)),
                    DataCell(isPending ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.approveAgency(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebTheme.successGreen, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('Approve'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => controller.revokeAgency(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('Revoke'),
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
        : status == 'pending' ? WebTheme.warningAmber
        : WebTheme.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}