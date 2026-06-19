import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'App Settings',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadSettings(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Configuration', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    _buildSettingsForm(context),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSettingsForm(BuildContext context) {
    final keys = controller.settings.keys.toList()..sort();
    final localCtrls = <String, TextEditingController>{};

    for (final key in keys) {
      localCtrls[key] = TextEditingController(
        text: controller.settings[key]?.toString() ?? '',
      );
    }

    return Form(
      child: Column(
        children: [
          ...keys.map((key) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: TextField(
              controller: localCtrls[key],
              decoration: InputDecoration(
                labelText: key.replaceAll('_', ' ').capitalizeFirst,
                hintText: controller.settings[key]?.toString() ?? '',
              ),
            ),
          )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: controller.isSaving.value ? null : () {
                final updated = <String, dynamic>{};
                for (final key in keys) {
                  updated[key] = localCtrls[key]!.text;
                }
                controller.saveSettings(updated);
              },
              child: controller.isSaving.value
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text('Save Settings'),
            )),
          ),
        ],
      ),
    );
  }
}

