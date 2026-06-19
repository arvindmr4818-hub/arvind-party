import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audit_log_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class AuditLogView extends GetView<AuditLogController> {
  const AuditLogView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Audit Logs',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadLogs(),
          tooltip: 'Refresh',
        ),
      ],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: WebTheme.cardDark,
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: controller.fromDateCtrl,
                    decoration: const InputDecoration(labelText: 'From Date', hintText: 'YYYY-MM-DD', prefixIcon: Icon(Icons.date_range, size: 20)),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: TextField(
                    controller: controller.toDateCtrl,
                    decoration: const InputDecoration(labelText: 'To Date', hintText: 'YYYY-MM-DD', prefixIcon: Icon(Icons.date_range, size: 20)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => controller.loadLogs(
                    from: controller.fromDateCtrl.text.trim(),
                    to: controller.toDateCtrl.text.trim(),
                  ),
                  child: const Text('Filter'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.logs.isEmpty) return const Center(child: Text('No audit logs', style: TextStyle(color: WebTheme.textSecondary)));
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Admin')),
                        DataColumn(label: Text('Action')),
                        DataColumn(label: Text('Target')),
                        DataColumn(label: Text('Details')),
                        DataColumn(label: Text('Timestamp')),
                      ],
                      rows: controller.logs.map((l) => DataRow(cells: [
                        DataCell(Text(l['admin_id']?.toString() ?? l['admin_name']?.toString() ?? 'N/A')),
                        DataCell(Text(l['action']?.toString() ?? 'N/A')),
                        DataCell(Text(l['target']?.toString() ?? 'N/A')),
                        DataCell(Text(l['details']?.toString() ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis)),
                        DataCell(Text(l['created_at']?.toString() ?? '')),
                      ])).toList(),
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
}