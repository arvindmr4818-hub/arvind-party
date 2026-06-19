import 'package:flutter/material.dart';
import '../models/wallet_model.dart';

class TransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  const TransactionItem({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    IconData icon; Color color;
    switch (transaction.type) {
      case TransactionType.recharge: icon = Icons.arrow_downward; color = Colors.green; break;
      case TransactionType.withdraw: icon = Icons.arrow_upward; color = Colors.red; break;
      case TransactionType.gift_sent: icon = Icons.card_giftcard; color = Colors.purple; break;
      case TransactionType.gift_received: icon = Icons.card_giftcard; color = Colors.orange; break;
      case TransactionType.event_reward: icon = Icons.star; color = Colors.amber; break;
      case TransactionType.system: icon = Icons.settings; color = Colors.blue; break;
    }
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
      title: Text(transaction.description ?? transaction.type.name.toUpperCase()),
      subtitle: Row(children: [
        Text(transaction.currency.name.toUpperCase(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: transaction.status == TransactionStatus.completed ? Colors.green.shade100 : transaction.status == TransactionStatus.pending ? Colors.orange.shade100 : Colors.red.shade100, borderRadius: BorderRadius.circular(4)), child: Text(transaction.status.name, style: TextStyle(fontSize: 10, color: transaction.status == TransactionStatus.completed ? Colors.green : transaction.status == TransactionStatus.pending ? Colors.orange : Colors.red))),
      ]),
      trailing: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('${transaction.amount >= 0 ? '+' : ''}${transaction.amount}', style: TextStyle(fontWeight: FontWeight.bold, color: transaction.amount >= 0 ? Colors.green : Colors.red)),
        Text(_formatTime(transaction.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ]),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}/${date.month}';
  }
}