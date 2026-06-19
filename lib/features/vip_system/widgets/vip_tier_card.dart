// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/widgets/vip_tier_card.dart
// ARVIND PARTY - VIP TIER CARD WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/vip_model.dart';

class VIPTierCard extends StatelessWidget {
  final VIPTier tier;
  final VoidCallback onSelect;
  final bool isSelected;
  final bool isCurrentTier;

  const VIPTierCard({
    super.key,
    required this.tier,
    required this.onSelect,
    this.isSelected = false,
    this.isCurrentTier = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.blue 
                : isCurrentTier 
                    ? Colors.green 
                    : Colors.grey[300]!,
            width: isSelected || isCurrentTier ? 2 : 1,
          ),
          color: isSelected 
              ? Colors.blue[50] 
              : isCurrentTier 
                  ? Colors.green[50]
                  : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tier.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '₹${tier.price.toStringAsFixed(0)}/mo',
                    style: TextStyle(
                      color: Colors.green[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tier.description,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tier.features.take(3).map((feature) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.blue[800],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (isCurrentTier)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Current Plan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}