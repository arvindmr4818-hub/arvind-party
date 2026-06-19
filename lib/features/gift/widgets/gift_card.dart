import 'package:flutter/material.dart';
import '../models/gift_model.dart';

class GiftCard extends StatelessWidget {
  final GiftModel gift;
  final VoidCallback onTap;
  const GiftCard({super.key, required this.gift, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                  child: Image.network(
                    gift.previewImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade200),
                  ),
                ),
                _badge(gift.type.name.toUpperCase(), alignment: Alignment.topLeft),
                if (gift.category != GiftCategory.normal)
                  _badge(gift.category.name.toUpperCase(), alignment: Alignment.topRight),
                if (gift.isLucky)
                  const Positioned(bottom: 8, left: 8, child: Icon(Icons.star, color: Colors.amber, size: 16)),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gift.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Row(
                    children: [
                      const Icon(Icons.monetization_on, size: 14, color: Colors.orange),
                      Text(' ${gift.price.toInt()}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      if (gift.comboCount != null)
                        Text(' x${gift.comboCount}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, {Alignment alignment = Alignment.topLeft}) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ),
    );
  }
}