import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/leaderboard_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Leaderboard Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadLeaderboard(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Leaderboard Rankings', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _confirmReset(),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reset Leaderboard'),
                    style: ElevatedButton.styleFrom(backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: controller.entries.isEmpty
                  ? const Center(child: Text('No leaderboard data', style: TextStyle(color: WebTheme.textSecondary)))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Rank')),
                              DataColumn(label: Text('User')),
                              DataColumn(label: Text('Score')),
                              DataColumn(label: Text('Level')),
                            ],
                            rows: controller.entries.asMap().entries.map((e) {
                              final entry = e.value;
                              return DataRow(cells: [
                                DataCell(Text('#${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text(entry['username']?.toString() ?? entry['uid']?.toString() ?? 'N/A')),
                                DataCell(Text(entry['score']?.toString() ?? '0')),
                                DataCell(Text(entry['level']?.toString() ?? 'N/A')),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  void _confirmReset() {
    Get.dialog(AlertDialog(
      title: const Text('Reset Leaderboard'),
      content: const Text('Are you sure? This will clear all leaderboard rankings.'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () { controller.resetLeaderboard(); Get.back(); },
          style: ElevatedButton.styleFrom(backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white),
          child: const Text('Reset'),
        ),
      ],
    ));
  }
}