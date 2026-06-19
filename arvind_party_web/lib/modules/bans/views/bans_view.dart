import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bans_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class BansView extends GetView<BansController> {
  const BansView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Ban Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: WebTheme.primaryOrange),
          onPressed: () => _showCreateBanDialog(),
          tooltip: 'Apply Ban',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadBans(),
          tooltip: 'Refresh',
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.bans.isEmpty) {
                return const Center(
                  child: Text('No active bans', style: TextStyle(color: WebTheme.textSecondary)),
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
                        DataColumn(label: Text('Type')),
                        DataColumn(label: Text('Reason')),
                        DataColumn(label: Text('Duration')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.bans.map((b) {
                        return DataRow(cells: [
                          DataCell(Text(b['user_id']?.toString() ?? 'N/A')),
                          DataCell(Text(b['type']?.toString() ?? 'user')),
                          DataCell(Text(b['reason']?.toString() ?? 'N/A')),
                          DataCell(Text(b['duration']?.toString() ?? 'Permanent')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => controller.liftBan(b['id']?.toString() ?? ''),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WebTheme.successGreen, foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('Lift Ban'),
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

  void _showCreateBanDialog() {
    Get.dialog(AlertDialog(
      title: const Text('Apply Ban'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: controller.banUserIdCtrl, decoration: const InputDecoration(labelText: 'User ID *', hintText: 'Enter user ID or UID')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: controller.banTypeCtrl.text,
          decoration: const InputDecoration(labelText: 'Ban Type'),
          items: const [
            DropdownMenuItem(value: 'user', child: Text('User')),
            DropdownMenuItem(value: 'device', child: Text('Device')),
            DropdownMenuItem(value: 'ip', child: Text('IP')),
          ],
          onChanged: (v) { if (v != null) controller.banTypeCtrl.text = v; },
        ),
        const SizedBox(height: 12),
        TextField(controller: controller.banReasonCtrl, decoration: const InputDecoration(labelText: 'Reason'), maxLines: 2),
        const SizedBox(height: 12),
        TextField(controller: controller.banDurationCtrl, decoration: const InputDecoration(labelText: 'Duration', hintText: 'Leave empty for permanent')),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.createBan();
            Get.back();
          },
          child: const Text('Apply Ban'),
        ),
      ],
    ));
  }
}