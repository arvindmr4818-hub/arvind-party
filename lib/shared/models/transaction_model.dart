// lib/shared/models/transaction_model.dart
class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'recharge', 'withdraw', 'gift_sent', 'gift_received', 'reward', 'commission'
  final int amount;
  final int balanceAfter;
  final String description;
  final String status; // 'pending', 'completed', 'failed'
  final String? referenceId; // payment gateway transaction id
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    required this.status,
    this.referenceId,
    required this.createdAt,
    this.metadata,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'recharge',
      amount: json['amount'] is int ? json['amount'] : int.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      balanceAfter: json['balanceAfter'] is int ? json['balanceAfter'] : int.tryParse(json['balanceAfter']?.toString() ?? '0') ?? 0,
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      referenceId: json['referenceId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'type': type,
        'amount': amount,
        'balanceAfter': balanceAfter,
        'description': description,
        'status': status,
        'referenceId': referenceId,
        'createdAt': createdAt.toIso8601String(),
        'metadata': metadata,
      };
}

class RechargePackageModel {
  final String id;
  final String name;
  final int coins;
  final double priceUsd;
  final double priceInr;
  final int bonusCoins;
  final String? imageUrl;
  final bool isPopular;

  RechargePackageModel({
    required this.id,
    required this.name,
    required this.coins,
    required this.priceUsd,
    required this.priceInr,
    required this.bonusCoins,
    this.imageUrl,
    required this.isPopular,
  });

  int get totalCoins => coins + bonusCoins;

  factory RechargePackageModel.fromJson(Map<String, dynamic> json) {
    return RechargePackageModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      coins: json['coins'] is int ? json['coins'] : int.tryParse(json['coins']?.toString() ?? '0') ?? 0,
      priceUsd: (json['priceUsd'] is num ? json['priceUsd'] : double.tryParse(json['priceUsd']?.toString() ?? '0') ?? 0).toDouble(),
      priceInr: (json['priceInr'] is num ? json['priceInr'] : double.tryParse(json['priceInr']?.toString() ?? '0') ?? 0).toDouble(),
      bonusCoins: json['bonusCoins'] is int ? json['bonusCoins'] : int.tryParse(json['bonusCoins']?.toString() ?? '0') ?? 0,
      imageUrl: json['imageUrl']?.toString(),
      isPopular: json['isPopular'] is bool ? json['isPopular'] : false,
    );
  }
}
