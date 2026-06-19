// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/agency/presentation/views/agency_ranking_screen.dart
// ARVIND PARTY - AGENCY RANKING SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AgencyRankingScreen extends StatelessWidget {
  const AgencyRankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agency Ranking')),
      body: const Center(child: Text('Agency ranking coming soon', style: TextStyle(color: Colors.grey))),
    );
  }
}