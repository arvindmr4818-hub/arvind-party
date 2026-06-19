import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/security_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class SecurityView extends GetView<SecurityController> {
  const SecurityView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Security Center',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadLogins(),
          tooltip: 'Refresh',
        ),
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Block IP Address', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            controller: controller.ipCtrl,
                            decoration: const InputDecoration(labelText: 'IP Address', hintText: '192.168.1.1'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 250,
                          child: TextField(
                            controller: controller.reasonCtrl,
                            decoration: const InputDecoration(labelText: 'Reason'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: controller.blockIp,
                          style: ElevatedButton.styleFrom(backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white),
                          child: const Text('Block IP'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.logins.isEmpty) return const Center(child: Text('No login activity', style: TextStyle(color: WebTheme.textSecondary)));
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('IP Address')),
                        DataColumn(label: Text('Device')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Time')),
                      ],
                      rows: controller.logins.map((l) => DataRow(cells: [
                        DataCell(Text(l['username']?.toString() ?? l['uid']?.toString() ?? 'N/A')),
                        DataCell(Text(l['ip']?.toString() ?? 'N/A')),
                        DataCell(Text(l['device']?.toString() ?? 'N/A')),
                        DataCell(_statusBadge(l['status']?.toString() ?? '')),
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

  Widget _statusBadge(String status) {
    final color = status == 'success' ? WebTheme.successGreen : WebTheme.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}