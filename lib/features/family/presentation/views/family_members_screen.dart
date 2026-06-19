// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_members_screen.dart
// ARVIND PARTY - FAMILY MEMBERS SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class FamilyMembersScreen extends StatelessWidget {
  const FamilyMembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Members')),
      body: const Center(child: Text('Family members coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}