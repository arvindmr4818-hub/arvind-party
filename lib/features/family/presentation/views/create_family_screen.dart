// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/create_family_screen.dart
// ARVIND PARTY - CREATE FAMILY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class CreateFamilyScreen extends StatelessWidget {
  const CreateFamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Family')),
      body: const Center(child: Text('Create family form coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}