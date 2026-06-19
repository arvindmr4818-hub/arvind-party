// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/family/presentation/views/family_ranking_screen.dart
// ARVIND PARTY - FAMILY RANKING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class FamilyRankingScreen extends StatelessWidget {
  const FamilyRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family Ranking')),
      body: const Center(child: Text('Family ranking coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}