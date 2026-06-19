// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_chat_screen.dart
// ARVIND PARTY - FAMILY CHAT SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class FamilyChatScreen extends StatelessWidget {
  const FamilyChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Chat')),
      body: const Center(child: Text('Family chat coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}