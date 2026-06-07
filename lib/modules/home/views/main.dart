// lib/modules/home/views/main.dart
// Re-export redirect: this file is intentionally minimal because the web
// admin entrypoint lives in /arvind_party_web/ as a separate Flutter project.
import 'package:flutter/material.dart';

void main() {
  runApp(const _HomeRedirect());
}

class _HomeRedirect extends StatelessWidget {
  const _HomeRedirect();
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('Use /lib/main.dart for the mobile app.')),
      ),
    );
  }
}
