import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/events_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class EventsView extends GetView<EventsController> {
  const EventsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Event Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: WebTheme.primaryOrange),
          onPressed: () => _showEventDialog(null),
          tooltip: 'Create Event',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadEvents(),
          tooltip: 'Refresh',
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              if (controller.events.isEmpty) return const Center(child: Text('No events', style: TextStyle(color: WebTheme.textSecondary)));
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Title')),
                        DataColumn(label: Text('Reward')),
                        DataColumn(label: Text('Start Date')),
                        DataColumn(label: Text('End Date')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: controller.events.map((e) => DataRow(cells: [
                        DataCell(Text(e['title']?.toString() ?? 'N/A')),
                        DataCell(Text(e['reward']?.toString() ?? 'N/A')),
                        DataCell(Text(e['start_date']?.toString() ?? '')),
                        DataCell(Text(e['end_date']?.toString() ?? '')),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: () => _showEventDialog(e),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11),
                              ),
                              child: const Text('Edit'),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () => controller.deleteEvent(e['id']?.toString() ?? ''),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: WebTheme.errorRed, foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero, textStyle: const TextStyle(fontSize: 11),
                              ),
                              child: const Text('Delete'),
                            ),
                          ],
                        )),
                      ])).toList(),
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

  void _showEventDialog(Map<String, dynamic>? existing) {
    if (existing != null) {
      controller.titleCtrl.text = existing['title']?.toString() ?? '';
      controller.descriptionCtrl.text = existing['description']?.toString() ?? '';
      controller.rewardCtrl.text = existing['reward']?.toString() ?? '';
      controller.startDateCtrl.text = existing['start_date']?.toString() ?? '';
      controller.endDateCtrl.text = existing['end_date']?.toString() ?? '';
    } else {
      controller.titleCtrl.clear();
      controller.descriptionCtrl.clear();
      controller.rewardCtrl.clear();
      controller.startDateCtrl.clear();
      controller.endDateCtrl.clear();
    }

    Get.dialog(AlertDialog(
      title: Text(existing != null ? 'Edit Event' : 'Create Event'),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: controller.titleCtrl, decoration: const InputDecoration(labelText: 'Title *')),
          const SizedBox(height: 12),
          TextField(controller: controller.descriptionCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
          const SizedBox(height: 12),
          TextField(controller: controller.rewardCtrl, decoration: const InputDecoration(labelText: 'Reward')),
          const SizedBox(height: 12),
          TextField(controller: controller.startDateCtrl, decoration: const InputDecoration(labelText: 'Start Date', hintText: 'YYYY-MM-DD')),
          const SizedBox(height: 12),
          TextField(controller: controller.endDateCtrl, decoration: const InputDecoration(labelText: 'End Date', hintText: 'YYYY-MM-DD')),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (existing != null) {
              controller.updateEvent(existing['id']?.toString() ?? '');
            } else {
              controller.createEvent();
            }
            Get.back();
          },
          child: const Text('Save'),
        ),
      ],
    ));
  }
}