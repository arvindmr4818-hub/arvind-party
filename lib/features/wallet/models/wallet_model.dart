enum CurrencyType { coins, diamonds, beans }
enum TransactionType { recharge, withdraw, gift_sent, gift_received, event_reward, system }
enum TransactionStatus { pending, completed, failed }

class WalletBalance {
  final int coins;
  final int diamonds;
  final int beans;
  const WalletBalance({required this.coins, required this.diamonds, required this.beans});
  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(coins: json['coins'] ?? 0, diamonds: json['diamonds'] ?? 0, beans: json['beans'] ?? 0);

  WalletBalance copyWith({int? coins, int? diamonds, int? beans}) {
    return WalletBalance(
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      beans: beans ?? this.beans,
    );
  }
}

class RechargePackage {
  final String id;
  final String name;
  final double price;
  final int coins;
  final int diamonds;
  final int beans;
  final bool isPopular;
  const RechargePackage({required this.id, required this.name, required this.price, required this.coins, required this.diamonds, required this.beans, this.isPopular = false});
  factory RechargePackage.fromJson(Map<String, dynamic> json) => RechargePackage(id: json['id'], name: json['name'], price: (json['price'] ?? 0).toDouble(), coins: json['coins'] ?? 0, diamonds: json['diamonds'] ?? 0, beans: json['beans'] ?? 0, isPopular: json['isPopular'] ?? false);
}

class WithdrawMethod {
  final String id;
  final String name;
  final String iconUrl;
  final double minAmount;
  final double maxAmount;
  final double feePercentage;
  const WithdrawMethod({required this.id, required this.name, required this.iconUrl, required this.minAmount, required this.maxAmount, required this.feePercentage});
  factory WithdrawMethod.fromJson(Map<String, dynamic> json) => WithdrawMethod(id: json['id'], name: json['name'], iconUrl: json['iconUrl'] ?? 'https://picsum.photos/seed/withdraw/50', minAmount: (json['minAmount'] ?? 0).toDouble(), maxAmount: (json['maxAmount'] ?? 0).toDouble(), feePercentage: (json['feePercentage'] ?? 0.0).toDouble());
}

class TransactionModel {
  final String id;
  final TransactionType type;
  final CurrencyType currency;
  final int amount;
  final String? description;
  final TransactionStatus status;
  final String? paymentMethodId;
  final DateTime createdAt;
  const TransactionModel({required this.id, required this.type, required this.currency, required this.amount, this.description, required this.status, this.paymentMethodId, required this.createdAt});
  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(id: json['id'], type: TransactionType.values.firstWhere((e) => e.name == json['type']), currency: CurrencyType.values.firstWhere((e) => e.name == json['currency']), amount: json['amount'] ?? 0, description: json['description'], status: TransactionStatus.values.firstWhere((e) => e.name == json['status']), paymentMethodId: json['paymentMethodId'], createdAt: DateTime.parse(json['createdAt']));
}