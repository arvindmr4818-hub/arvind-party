import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/vip_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class VipView extends GetView<VipController> {
  const VipView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'VIP Plans',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: WebTheme.primaryOrange),
          onPressed: () => _showPlanDialog(null),
          tooltip: 'Add Plan',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadPlans(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.plans.isEmpty) {
          return const Center(
            child: Text('No VIP plans', style: TextStyle(color: WebTheme.textSecondary)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Plan Name')),
                  DataColumn(label: Text('Price')),
                  DataColumn(label: Text('Duration')),
                  DataColumn(label: Text('Benefits')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.plans.map((p) {
                  return DataRow(cells: [
                    DataCell(Text(p['name']?.toString() ?? 'N/A')),
                    DataCell(Text(p['price']?.toString() ?? '0')),
                    DataCell(Text(p['duration']?.toString() ?? 'N/A')),
                    DataCell(Text(p['benefits']?.toString() ?? 'N/A')),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _showPlanDialog(p),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showPlanDialog(Map<String, dynamic>? existing) {
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: existing?['price']?.toString() ?? '');
    final durationCtrl = TextEditingController(text: existing?['duration']?.toString() ?? '');
    final benefitsCtrl = TextEditingController(text: existing?['benefits']?.toString() ?? '');

    Get.dialog(AlertDialog(
      title: Text(existing != null ? 'Edit VIP Plan' : 'Add VIP Plan'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Plan Name')),
        const SizedBox(height: 12),
        TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Duration (days)'), keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        TextField(controller: benefitsCtrl, decoration: const InputDecoration(labelText: 'Benefits'), maxLines: 3),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final data = {
              'name': nameCtrl.text.trim(),
              'price': priceCtrl.text.trim(),
              'duration': durationCtrl.text.trim(),
              'benefits': benefitsCtrl.text.trim(),
            };
            if (existing != null) {
              controller.updatePlan(existing['id']?.toString() ?? '', data);
            } else {
              controller.createPlan(data);
            }
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }
}