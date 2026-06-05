// arvind_party_web/lib/modules/users/views/users_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/users_controller.dart';
import '../../../shared/widgets/sidebar_widget.dart';

class UsersView extends StatelessWidget {
  const UsersView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(UsersController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Row(
        children: [
          const SidebarWidget(selected: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('User Management',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    const Spacer(),
                    IconButton(
                      onPressed: ctrl.loadUsers,
                      icon: const Icon(Icons.refresh, color: Colors.white54),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (ctrl.isLoading.value) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF8906)));
                      }
                      if (ctrl.users.isEmpty) {
                        return const Center(
                            child: Text('No users found',
                                style: TextStyle(color: Colors.white54)));
                      }
                      return _UsersTable(ctrl: ctrl);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UsersTable extends StatelessWidget {
  final UsersController ctrl;
  const _UsersTable({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15141F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2940)),
      ),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('User ID',  style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Name',     style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Level',    style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Coins',    style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Diamonds', style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Status',   style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Actions',  style: TextStyle(color: Colors.white70))),
          ],
          rows: ctrl.users.map((u) {
            final user    = u as Map<String, dynamic>;
            final blocked = user['isBlocked'] == true;
            final id      = user['_id']?.toString() ?? '';
            return DataRow(cells: [
              DataCell(Text(user['userId']?.toString() ?? '-',
                  style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 12))),
              DataCell(Row(children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFF2A2940),
                  backgroundImage: (user['avatar']?.toString() ?? '').isNotEmpty
                      ? NetworkImage(user['avatar'].toString()) : null,
                  child: (user['avatar']?.toString() ?? '').isEmpty
                      ? const Icon(Icons.person, size: 14, color: Colors.white54) : null,
                ),
                const SizedBox(width: 8),
                Text(user['name']?.toString() ?? 'Unknown',
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ])),
              DataCell(Text('Lv.${user['level'] ?? 1}',
                  style: const TextStyle(color: Color(0xFFFFC107)))),
              DataCell(Text('${user['coins'] ?? 0}',
                  style: const TextStyle(color: Color(0xFFFF8906)))),
              DataCell(Text('${user['diamonds'] ?? 0}',
                  style: const TextStyle(color: Color(0xFF64B5F6)))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: blocked
                      ? const Color(0xFFCF6679).withOpacity(0.15)
                      : const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(blocked ? 'Blocked' : 'Active',
                    style: TextStyle(
                        color: blocked
                            ? const Color(0xFFCF6679)
                            : const Color(0xFF4CAF50),
                        fontSize: 12)),
              )),
              DataCell(Row(children: [
                // Block/Unblock
                IconButton(
                  icon: Icon(blocked ? Icons.lock_open : Icons.block,
                      color: blocked
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFCF6679),
                      size: 18),
                  tooltip: blocked ? 'Unblock' : 'Block',
                  onPressed: () => blocked
                      ? ctrl.unblockUser(id)
                      : ctrl.blockUser(id),
                ),
                // Add Coins
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: Color(0xFFFF8906), size: 18),
                  tooltip: 'Add 1000 Coins',
                  onPressed: () => ctrl.adjustCoins(id, 1000),
                ),
              ])),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
