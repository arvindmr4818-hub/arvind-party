import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class CurrencyCard extends StatelessWidget {
  final CurrencyType type;
  final int amount;
  const CurrencyCard({super.key, required this.type, required this.amount});

  @override
  Widget build(BuildContext context) {
    IconData icon; Color color; String label;
    switch (type) {
      case CurrencyType.coins: icon = Icons.monetization_on; color = Colors.orange; label = 'Coins'; break;
      case CurrencyType.diamonds: icon = Icons.diamond; color = Colors.cyan; label = 'Diamonds'; break;
      case CurrencyType.beans: icon = Icons.coffee; color = Colors.brown; label = 'Beans'; break;
    }
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Icon(icon, color: color, size: 28),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10))),
        ]),
        const SizedBox(height: 12),
        Text(amount.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}