import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/announcements_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class AnnouncementsView extends GetView<AnnouncementsController> {
  const AnnouncementsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Announcements',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadAnnouncements(),
          tooltip: 'Refresh',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send Announcement', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    TextField(controller: controller.titleCtrl, decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.title))),
                    const SizedBox(height: 12),
                    TextField(controller: controller.messageCtrl, decoration: const InputDecoration(labelText: 'Message *', prefixIcon: Icon(Icons.message)), maxLines: 4),
                    const SizedBox(height: 12),
                    TextField(controller: controller.targetCtrl, decoration: const InputDecoration(labelText: 'Target Audience', hintText: 'all, vip, agency (leave empty for all)')),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 200,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isSending.value ? null : controller.sendAnnouncement,
                        child: controller.isSending.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('Broadcast Announcement'),
                      )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Announcement History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.announcements.isEmpty) return const Text('No announcements sent', style: TextStyle(color: WebTheme.textSecondary));
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Message')),
                      DataColumn(label: Text('Target')),
                      DataColumn(label: Text('Sent At')),
                    ],
                    rows: controller.announcements.map((a) => DataRow(cells: [
                      DataCell(Text(a['title']?.toString() ?? 'N/A')),
                      DataCell(Text(a['message']?.toString() ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis)),
                      DataCell(Text(a['target_audience']?.toString() ?? 'All')),
                      DataCell(Text(a['created_at']?.toString() ?? '')),
                    ])).toList(),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}