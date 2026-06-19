// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_salary_screen.dart
// ARVIND PARTY - AGENCY SALARY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AgencySalaryScreen extends StatelessWidget {
  const AgencySalaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Salary')),
      body: const Center(child: Text('Agency salary coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}