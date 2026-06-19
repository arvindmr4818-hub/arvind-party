import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tickets_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class TicketsView extends GetView<TicketsController> {
  const TicketsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Support Tickets',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadTickets(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.tickets.isEmpty) return const Center(child: Text('No tickets', style: TextStyle(color: WebTheme.textSecondary)));
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('User')),
                  DataColumn(label: Text('Subject')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Date')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: controller.tickets.map((t) {
                  final id = t['id']?.toString() ?? '';
                  final status = t['status']?.toString() ?? 'open';
                  return DataRow(cells: [
                    DataCell(Text(t['username']?.toString() ?? t['uid']?.toString() ?? 'N/A')),
                    DataCell(Text(t['subject']?.toString() ?? 'N/A', maxLines: 2, overflow: TextOverflow.ellipsis)),
                    DataCell(_statusBadge(status)),
                    DataCell(Text(t['created_at']?.toString() ?? '')),
                    DataCell(
                      ElevatedButton(
                        onPressed: () => _showReplyDialog(id, t['subject']?.toString() ?? ''),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 12),
                        ),
                        child: const Text('Reply'),
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

  Widget _statusBadge(String status) {
    final color = status == 'open' ? WebTheme.warningAmber
        : status == 'closed' ? WebTheme.successGreen
        : WebTheme.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  void _showReplyDialog(String ticketId, String subject) {
    controller.replyCtrl.clear();
    Get.dialog(AlertDialog(
      title: Text('Reply to Ticket: $subject'),
      content: SizedBox(
        width: 400,
        child: TextField(
          controller: controller.replyCtrl,
          decoration: const InputDecoration(labelText: 'Your Reply', hintText: 'Type your response...'),
          maxLines: 5,
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.replyToTicket(ticketId);
            Get.back();
          },
          child: const Text('Send Reply'),
        ),
      ],
    ));
  }
}