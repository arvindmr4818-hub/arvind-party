import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/family_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class FamilyView extends GetView<FamilyController> {
  const FamilyView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Family Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadFamilies(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.families.isEmpty) {
          return const Center(
            child: Text('No families found', style: TextStyle(color: WebTheme.textSecondary)),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Family Name')),
                  DataColumn(label: Text('Head')),
                  DataColumn(label: Text('Members')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.families.map((f) {
                  final id = f['id']?.toString() ?? '';
                  return DataRow(cells: [
                    DataCell(Text(f['name']?.toString() ?? 'N/A')),
                    DataCell(Text(f['head']?.toString() ?? 'N/A')),
                    DataCell(Text(f['members']?.toString() ?? '0')),
                    DataCell(Text(f['status']?.toString() ?? 'active')),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _confirmDelete(id, f['name']?.toString() ?? ''),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Delete'),
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

  void _confirmDelete(String id, String name) {
    Get.dialog(AlertDialog(
      title: const Text('Delete Family'),
      content: Text('Are you sure you want to delete "$name"?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { controller.deleteFamily(id); Get.back(); },
          style: ElevatedButton.styleFrom(backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white),
          child: const Text('Delete'),
        ),
      ],
    ));
  }
}