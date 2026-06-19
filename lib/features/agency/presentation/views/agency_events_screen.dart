// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_events_screen.dart
// ARVIND PARTY - AGENCY EVENTS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AgencyEventsScreen extends StatelessWidget {
  const AgencyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Events')),
      body: const Center(child: Text('Agency events coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}