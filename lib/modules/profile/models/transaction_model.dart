class TransactionModel {
  final String id;
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final int amount; 
  final String type;
  final String status;
  final DateTime? createdAt;

  TransactionModel({
    required this.id,
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.amount,
    required this.type,
    required this.status,
    this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] ?? '',
      razorpayOrderId: json['razorpayOrderId'] ?? '',
      razorpayPaymentId: json['razorpayPaymentId'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}