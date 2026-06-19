// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_members_screen.dart
// ARVIND PARTY - AGENCY MEMBERS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AgencyMembersScreen extends StatelessWidget {
  const AgencyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Members')),
      body: const Center(child: Text('Agency members coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}