// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/create_agency_screen.dart
// ARVIND PARTY - CREATE AGENCY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class CreateAgencyScreen extends StatelessWidget {
  const CreateAgencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Agency')),
      body: const Center(child: Text('Create agency form coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}