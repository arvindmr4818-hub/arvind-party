import 'package:flutter/material.dart';

class ReadReceiptIndicator extends StatelessWidget {
  final bool isRead;
  final DateTime? readAt;

  const ReadReceiptIndicator({
    super.key,
    required this.isRead,
    this.readAt,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRead) {
      return Icon(
        Icons.done,
        size: 14,
        color: Colors.grey[400],
      );
    }

    return const Tooltip(
      message: 'Read',
      child: Icon(
        Icons.done_all,
        size: 14,
        color: Colors.blue,
      ),
    );
  }
}