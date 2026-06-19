// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/widgets/payment_dialog.dart
// ARVIND PARTY - PAYMENT DIALOG WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../models/vip_model.dart';

class PaymentDialog extends StatelessWidget {
  final VIPTier tier;
  final Function(String) onPaymentMethodSelected;
  final bool isLoading;

  const PaymentDialog({
    super.key,
    required this.tier,
    required this.onPaymentMethodSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirm Purchase'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upgrade to ${tier.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            '₹${tier.price.toStringAsFixed(0)}/month',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${tier.durationDays} days subscription',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          const Text(
            'Select Payment Method:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _PaymentMethodButton(
            label: 'Razorpay',
            icon: Icons.credit_card,
            onTap: isLoading
                ? null
                : () {
                    onPaymentMethodSelected('razorpay');
                    Navigator.pop(context);
                  },
          ),
          const SizedBox(height: 8),
          _PaymentMethodButton(
            label: 'Google Pay',
            icon: Icons.payment,
            onTap: isLoading
                ? null
                : () {
                    onPaymentMethodSelected('gpay');
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}