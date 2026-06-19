import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class RechargePackageItem extends StatelessWidget {
  final RechargePackage package;
  final bool isSelected;
  final VoidCallback onTap;
  const RechargePackageItem({super.key, required this.package, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(package.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  if (package.isPopular) ...[
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)), child: const Text('Popular', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ]),
                const SizedBox(height: 4),
                Row(children: [
                  _badge('🪙 ${package.coins}', Colors.orange),
                  if (package.diamonds > 0) ...[const SizedBox(width: 6), _badge('💎 ${package.diamonds}', Colors.cyan)],
                  if (package.beans > 0) ...[const SizedBox(width: 6), _badge('🫘 ${package.beans}', Colors.brown)],
                ]),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('\$${package.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('USD', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
            if (isSelected) const Padding(padding: EdgeInsets.only(left: 8), child: Icon(Icons.check_circle, color: Colors.blue)),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(text, style: TextStyle(color: color, fontSize: 12)));
  }
}