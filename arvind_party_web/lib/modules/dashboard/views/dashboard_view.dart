// arvind_party_web/lib/modules/dashboard/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../shared/widgets/sidebar_widget.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DashboardController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Row(
        children: [
          const SidebarWidget(selected: 0),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      const Text('Dashboard',
                          style: TextStyle(fontSize: 26,
                              fontWeight: FontWeight.w700, color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        onPressed: ctrl.loadData,
                        icon: const Icon(Icons.refresh, color: Colors.white54),
                        tooltip: 'Refresh',
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Stat Cards
                    Wrap(
                      spacing: 16, runSpacing: 16,
                      children: [
                        _StatCard('Total Users',  ctrl.totalUsers.value.toString(),
                            Icons.people,    const Color(0xFF64B5F6)),
                        _StatCard('Online Now',   ctrl.onlineUsers.value.toString(),
                            Icons.circle,    const Color(0xFF4CAF50)),
                        _StatCard('Active Rooms', ctrl.activeRooms.value.toString(),
                            Icons.mic,       const Color(0xFFFF8906)),
                        _StatCard('New Today',    ctrl.newToday.value.toString(),
                            Icons.person_add, const Color(0xFFFFC107)),
                        _StatCard('Blocked',      ctrl.blockedUsers.value.toString(),
                            Icons.block,     const Color(0xFFCF6679)),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Active Rooms Table
                    const Text('Live Rooms',
                        style: TextStyle(fontSize: 18,
                            fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 12),
                    _ActiveRoomsTable(rooms: ctrl.rooms),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15141F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2940), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: const TextStyle(fontSize: 28,
                  fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 4),
          Text(title,
              style: const TextStyle(fontSize: 13, color: Color(0xFFB0B0C3))),
        ],
      ),
    );
  }
}

class _ActiveRoomsTable extends StatelessWidget {
  final List<dynamic> rooms;
  const _ActiveRoomsTable({required this.rooms});

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF15141F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2940)),
        ),
        child: const Center(
            child: Text('No active rooms', style: TextStyle(color: Color(0xFFB0B0C3)))),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15141F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2940)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Room ID', style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Title',   style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Online',  style: TextStyle(color: Colors.white70))),
            DataColumn(label: Text('Type',    style: TextStyle(color: Colors.white70))),
          ],
          rows: rooms.map((r) {
            final room = r as Map<String, dynamic>;
            return DataRow(cells: [
              DataCell(Text(room['roomId']?.toString() ?? '-',
                  style: const TextStyle(color: Color(0xFF64B5F6), fontSize: 13))),
              DataCell(Text(room['title']?.toString() ?? '-',
                  style: const TextStyle(color: Colors.white, fontSize: 13))),
              DataCell(Text(room['activeUsers']?.toString() ?? '0',
                  style: const TextStyle(color: Color(0xFF4CAF50)))),
              DataCell(Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: room['roomType'] == 'private'
                      ? const Color(0xFFCF6679).withOpacity(0.15)
                      : const Color(0xFF4CAF50).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(room['roomType']?.toString() ?? 'public',
                    style: TextStyle(
                      color: room['roomType'] == 'private'
                          ? const Color(0xFFCF6679)
                          : const Color(0xFF4CAF50),
                      fontSize: 12,
                    )),
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
