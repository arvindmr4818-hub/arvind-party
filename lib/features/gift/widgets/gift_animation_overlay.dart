import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/gift_model.dart';

class GiftAnimationOverlay extends StatelessWidget {
  final GiftModel gift;
  const GiftAnimationOverlay({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(0),
      child: Stack(
        children: [
          Container(color: Colors.black.withOpacity(0.3)),
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (gift.type == GiftType.static)
                  Image.network(gift.previewImageUrl, height: 200)
                else
                  Icon(_typeIcon(gift.type), size: 80, color: _typeColor(gift.type)),
                const SizedBox(height: 16),
                Text('${gift.name} Sent!', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (gift.isLucky) const Text('You got 250 coins back!', style: TextStyle(color: Colors.green)),
              ]),
            ),
          ),
          Positioned(top: 40, right: 20, child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Get.back())),
        ],
      ),
    );
  }

  IconData _typeIcon(GiftType t) {
    switch (t) {
      case GiftType.animated: return Icons.movie;
      case GiftType.svga: return Icons.animation;
      case GiftType.mp4: return Icons.play_circle;
      case GiftType.combo: return Icons.repeat;
      default: return Icons.card_giftcard;
    }
  }

  Color _typeColor(GiftType t) {
    switch (t) {
      case GiftType.animated: return Colors.blue;
      case GiftType.svga: return Colors.purple;
      case GiftType.mp4: return Colors.red;
      case GiftType.combo: return Colors.orange;
      default: return Colors.grey;
    }
  }
}