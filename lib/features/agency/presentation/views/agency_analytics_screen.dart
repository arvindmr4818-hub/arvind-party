// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_analytics_screen.dart
// ARVIND PARTY - AGENCY ANALYTICS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AgencyAnalyticsScreen extends StatelessWidget {
  const AgencyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Analytics')),
      body: const Center(child: Text('Agency analytics coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}