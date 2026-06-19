import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/rooms_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class RoomManagementView extends GetView<RoomsController> {
  const RoomManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Room Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadRooms(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.rooms.isEmpty) {
          return const Center(
            child: Text(
              'No rooms found',
              style: TextStyle(color: WebTheme.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Room ID')),
                  DataColumn(label: Text('Room Name')),
                  DataColumn(label: Text('Owner')),
                  DataColumn(label: Text('Members')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.rooms.map((room) {
                  final status = room['status']?.toString() ?? 'active';
                  final isActive = status == 'active';
                  final roomId = room['id']?.toString() ?? '';

                  return DataRow(cells: [
                    DataCell(Text(room['name']?.toString() ?? 'N/A')),
                    DataCell(Text(room['title']?.toString() ?? 'N/A')),
                    DataCell(Text(room['owner']?.toString() ?? 'N/A')),
                    DataCell(Text('${room['members']?.toString() ?? '0'} members')),
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
                          isActive ? 'Active' : 'Closed',
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
                        onPressed:
                            isActive ? () => controller.closeRoom(roomId) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: WebTheme.errorRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Force Close'),
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
}