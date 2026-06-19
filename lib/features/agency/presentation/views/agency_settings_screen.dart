// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_settings_screen.dart
// ARVIND PARTY - AGENCY SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AgencySettingsScreen extends StatelessWidget {
  const AgencySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Settings')),
      body: const Center(child: Text('Agency settings coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}