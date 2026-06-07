import 'package:flutter/material.dart';

class AvatarWithFrame extends StatelessWidget {
  final String avatarUrl;
  final String? frameUrl;
  final double radius;

  const AvatarWithFrame({
    Key? key,
    required this.avatarUrl,
    this.frameUrl,
    this.radius = 30.0, // Default size
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none, // Allows the frame to extend slightly outside
      children: [
        // 1. User Avatar
        CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(avatarUrl),
          onBackgroundImageError: (_, __) => const Icon(Icons.person),
        ),
        // 2. Equipped Frame (If available)
        if (frameUrl != null && frameUrl!.isNotEmpty)
          Image.network(
            frameUrl!,
            width: radius * 2.5, // Frame slightly larger than avatar
            height: radius * 2.5,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const SizedBox(), // Hide if frame fails to load
          ),
      ],
    );
  }
}