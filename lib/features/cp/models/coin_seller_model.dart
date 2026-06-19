class CoinSeller {
  final String id;
  final String name;
  final String type; // 'normal', 'super', 'official'
  final int coinsAvailable;
  final double pricePerCoin;
  final double rating;
  final int totalSales;
  final String status; // 'active', 'inactive'
  final String? phone;
  final DateTime createdAt;

  CoinSeller({
    required this.id,
    required this.name,
    required this.type,
    this.coinsAvailable = 0,
    this.pricePerCoin = 1.0,
    this.rating = 0.0,
    this.totalSales = 0,
    this.status = 'active',
    this.phone,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CoinSeller.fromJson(Map<String, dynamic> json) => CoinSeller(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    type: json['type'] ?? 'normal',
    coinsAvailable: json['coinsAvailable'] ?? 0,
    pricePerCoin: (json['pricePerCoin'] ?? 1.0).toDouble(),
    rating: (json['rating'] ?? 0.0).toDouble(),
    totalSales: json['totalSales'] ?? 0,
    status: json['status'] ?? 'active',
    phone: json['phone'],
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}

class RechargeRequest {
  final String id;
  final String sellerId;
  final String sellerName;
  final int coins;
  final double amount;
  final String status; // 'pending', 'approved', 'completed', 'rejected'
  final DateTime createdAt;

  RechargeRequest({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.coins = 0,
    this.amount = 0.0,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RechargeRequest.fromJson(Map<String, dynamic> json) => RechargeRequest(
    id: json['id'] ?? '',
    sellerId: json['sellerId'] ?? '',
    sellerName: json['sellerName'] ?? '',
    coins: json['coins'] ?? 0,
    amount: (json['amount'] ?? 0.0).toDouble(),
    status: json['status'] ?? 'pending',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}

class SettlementRecord {
  final String id;
  final String sellerId;
  final double amount;
  final String status;
  final DateTime createdAt;

  SettlementRecord({
    required this.id,
    required this.sellerId,
    this.amount = 0.0,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SettlementRecord.fromJson(Map<String, dynamic> json) => SettlementRecord(
    id: json['id'] ?? '',
    sellerId: json['sellerId'] ?? '',
    amount: (json['amount'] ?? 0.0).toDouble(),
    status: json['status'] ?? 'pending',
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
  );
}