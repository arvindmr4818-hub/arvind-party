// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_settings_screen.dart
// ARVIND PARTY - FAMILY SETTINGS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class FamilySettingsScreen extends StatelessWidget {
  const FamilySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Settings')),
      body: const Center(child: Text('Family settings coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}