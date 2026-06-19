import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Push Notifications',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadHistory(),
          tooltip: 'Refresh',
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Send Notification Form ─────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Send Push Notification', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 20),
                    TextField(controller: controller.titleCtrl, decoration: const InputDecoration(labelText: 'Title *', prefixIcon: Icon(Icons.title))),
                    const SizedBox(height: 12),
                    TextField(controller: controller.messageCtrl, decoration: const InputDecoration(labelText: 'Message *', prefixIcon: Icon(Icons.message)), maxLines: 3),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 200,
                      child: Obx(() => ElevatedButton(
                        onPressed: controller.isSending.value ? null : controller.sendNotification,
                        child: controller.isSending.value
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                            : const Text('Send Notification'),
                      )),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ─── History ────────────────────────────────────
            Text('Sent History', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.history.isEmpty) return const Text('No notifications sent yet', style: TextStyle(color: WebTheme.textSecondary));
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Title')),
                      DataColumn(label: Text('Message')),
                      DataColumn(label: Text('Sent At')),
                    ],
                    rows: controller.history.map((h) => DataRow(cells: [
                      DataCell(Text(h['title']?.toString() ?? 'N/A')),
                      DataCell(Text(h['message']?.toString() ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis)),
                      DataCell(Text(h['created_at']?.toString() ?? '')),
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