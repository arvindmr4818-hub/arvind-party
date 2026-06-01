class TransactionModel {
  final String title;
  final int amount;
  final String type;
  final DateTime createdAt;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
  });
}
