import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_roles_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class AdminRolesView extends GetView<AdminRolesController> {
  const AdminRolesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Admin Roles',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: WebTheme.primaryOrange),
          onPressed: () => _showRoleDialog(null),
          tooltip: 'Add Role',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadRoles(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.roles.isEmpty) return const Center(child: Text('No roles defined', style: TextStyle(color: WebTheme.textSecondary)));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Role Name')),
                  DataColumn(label: Text('Permissions')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.roles.map((r) => DataRow(cells: [
                  DataCell(Text(r['name']?.toString() ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(r['permissions']?.toString() ?? '{}', maxLines: 2, overflow: TextOverflow.ellipsis)),
                  DataCell(
                    ElevatedButton(
                      onPressed: () => _showRoleDialog(r),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Edit'),
                    ),
                  ),
                ])).toList(),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showRoleDialog(Map<String, dynamic>? existing) {
    final nameCtrl = TextEditingController(text: existing?['name']?.toString() ?? '');
    Get.dialog(AlertDialog(
      title: Text(existing != null ? 'Edit Role' : 'Create Role'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Role Name')),
        const SizedBox(height: 16),
        const Text('Permissions can be set via the API.', style: TextStyle(color: WebTheme.textSecondary, fontSize: 12)),
      ]),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (existing != null) {
              controller.updateRole(existing['id']?.toString() ?? '');
            } else {
              controller.createRole();
            }
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }
}