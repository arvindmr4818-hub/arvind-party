import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Report Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadReports(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.reports.isEmpty) {
          return const Center(
            child: Text('No reports found', style: TextStyle(color: WebTheme.textSecondary)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Reporter')),
                  DataColumn(label: Text('Reported User')),
                  DataColumn(label: Text('Reason')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.reports.map((r) {
                  final id = r['id']?.toString() ?? '';
                  final status = r['status']?.toString() ?? 'pending';
                  return DataRow(cells: [
                    DataCell(Text(r['reporter']?.toString() ?? 'N/A')),
                    DataCell(Text(r['reported_user']?.toString() ?? 'N/A')),
                    DataCell(Text(r['reason']?.toString() ?? 'N/A')),
                    DataCell(_statusBadge(status)),
                    DataCell(Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (status == 'pending')
                          ElevatedButton(
                            onPressed: () => controller.resolveReport(id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WebTheme.successGreen, foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11),
                            ),
                            child: const Text('Resolve'),
                          ),
                        const SizedBox(width: 4),
                        ElevatedButton(
                          onPressed: () => controller.deleteReport(id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    )),
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
    final color = status == 'resolved' ? WebTheme.successGreen : WebTheme.warningAmber;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}