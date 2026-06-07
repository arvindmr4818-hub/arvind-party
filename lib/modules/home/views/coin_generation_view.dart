// lib/modules/home/views/coin_generation_view.dart
// This is a mobile-app placeholder. The real "Coin Generation" admin view
// lives in the web panel project: /arvind_party_web/lib/modules/owner/views/
import 'package:flutter/material.dart';

class CoinGenerationView extends StatelessWidget {
  const CoinGenerationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coin Generation')),
      body: const Center(
        child: Text(
          'Coin Generation admin is available on the web panel only.\n'
          'Open /arvind_party_web/ to manage coin treasury.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
