import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/badge_controller.dart';

class BadgeDisplayWidget extends StatelessWidget {
  final BadgeController controller = Get.put(BadgeController());

  BadgeDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF8906)),
        );
      }

      if (controller.badges.isEmpty) {
        return const Text(
          "No badges earned yet.",
          style: TextStyle(color: Colors.white54),
        );
      }

      return Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: controller.badges.asMap().entries.map((entry) {
          final index = entry.key;
          final badge = entry.value;
          
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 400 + (index * 100)), // Staggered pop-in
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Tooltip(
              message: badge.description,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xff15141F),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFFF8906).withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF8906).withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    badge.iconUrl.isNotEmpty
                        ? Image.network(badge.iconUrl, width: 20, height: 20, errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber, size: 20))
                        : const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      badge.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}