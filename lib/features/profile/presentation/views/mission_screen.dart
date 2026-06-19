// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/views/mission_screen.dart
// ARVIND PARTY - MISSION SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class MissionScreen extends StatelessWidget {
  const MissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Missions')),
      body: const Center(
        child: Text('Daily missions coming soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}