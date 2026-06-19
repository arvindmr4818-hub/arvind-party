// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/auth/presentation/widgets/profile_header.dart
// ARVIND PARTY - PROFILE HEADER WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../../models/auth_model.dart';

class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback? onEditPressed;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
      ),
      child: Column(
        children: [
          // Profile Image
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            backgroundImage: user.profileImage != null
                ? NetworkImage(user.profileImage!)
                : null,
            child: user.profileImage == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),

          // Username & Email
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            user.email,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),

          // VIP Badge
          if (user.vipTier != 'free')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.yellow[600],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.vipTier.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Followers/Following
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: 'Followers',
                count: user.followers.length,
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.white30,
              ),
              _StatItem(
                label: 'Following',
                count: user.following.length,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Edit Button
          if (onEditPressed != null)
            ElevatedButton(
              onPressed: onEditPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: const Text(
                'Edit Profile',
                style: TextStyle(color: Color(0xFF667EEA)),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int count;

  const _StatItem({
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}