// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/profile/presentation/views/user_profile_view.dart
// ARVIND PARTY - USER PROFILE VIEW
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: const Center(
        child: Text('User profile view coming soon', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}