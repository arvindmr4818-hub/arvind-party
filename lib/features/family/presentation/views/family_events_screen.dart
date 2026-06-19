// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_events_screen.dart
// ARVIND PARTY - FAMILY EVENTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class FamilyEventsScreen extends StatelessWidget {
  const FamilyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Events')),
      body: const Center(child: Text('Family events coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}