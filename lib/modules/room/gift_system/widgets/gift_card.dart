import 'package:flutter/material.dart';
import '../models/gift_model.dart';

class GiftCard extends StatelessWidget {
  final GiftModel gift;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftCard({
    super.key,
    required this.gift,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffFF8906).withOpacity(0.05)
              : const Color(0xff1A1924),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xffFF8906)
                : Colors.white.withOpacity(0.03),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Core Identity Content Canvas
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Large Graphics Emoji Asset representation
                  Text(
                    gift.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 6),

                  // 2. Gift Title
                  Text(
                    gift.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),

                  // 3. Digital Coin Pricing Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("🪙", style: TextStyle(fontSize: 9)),
                      const SizedBox(width: 2),
                      Text(
                        "${gift.price}",
                        style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Premium Special Badges Overlay (Top Left Corner tags logic rules)
            if (gift.isFullScreen || gift.isLuckyGift)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color:
                        gift.isLuckyGift ? Colors.green : Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    gift.isLuckyGift ? "LUCKY" : "MEGA",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
