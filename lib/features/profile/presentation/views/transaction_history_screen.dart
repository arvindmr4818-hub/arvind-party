// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/views/transaction_history_screen.dart
// ARVIND PARTY - TRANSACTION HISTORY SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: const Center(
        child: Text('Transaction history coming soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}