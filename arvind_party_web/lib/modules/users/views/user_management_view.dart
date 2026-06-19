import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class UserManagementView extends GetView<UsersController> {
  const UserManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'User Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadUsers(),
          tooltip: 'Refresh',
        ),
      ],
      body: Column(
        children: [
          // ─── Search Bar ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            color: WebTheme.cardDark,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search by UID or name...',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) => controller.searchUsers(value),
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 12),
                Obx(() => Text(
                      '${controller.totalUsers.value} users',
                      style: const TextStyle(
                        color: WebTheme.textSecondary,
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),

          // ─── Users Table ─────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.users.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(color: WebTheme.textSecondary),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('UID')),
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Level')),
                        DataColumn(label: Text('Coins')),
                        DataColumn(label: Text('Diamonds')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.users.map((user) {
                        final status = user['status']?.toString() ?? 'active';
                        final isActive = status == 'active';
                        final userId = user['id']?.toString() ?? '';

                        return DataRow(cells: [
                          DataCell(Text(user['uid']?.toString() ?? 'N/A')),
                          DataCell(Text(user['name']?.toString() ?? 'N/A')),
                          DataCell(Text('Lv.${user['level']?.toString() ?? '0'}')),
                          DataCell(Text(user['coins']?.toString() ?? '0')),
                          DataCell(Text(user['diamonds']?.toString() ?? '0')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? WebTheme.successGreen.withValues(alpha: 0.15)
                                    : WebTheme.errorRed.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isActive ? 'Active' : 'Blocked',
                                style: TextStyle(
                                  color: isActive
                                      ? WebTheme.successGreen
                                      : WebTheme.errorRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => controller.toggleBlockStatus(
                                userId,
                                status,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isActive
                                    ? WebTheme.errorRed
                                    : WebTheme.successGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                minimumSize: Size.zero,
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: Text(isActive ? 'Block' : 'Unblock'),
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
}