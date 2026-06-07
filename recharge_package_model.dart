class RechargePackage {
  final String id;
  final int coins;
  final double priceUsd;

  RechargePackage({
    required this.id,
    required this.coins,
    required this.priceUsd,
  });

  factory RechargePackage.fromJson(Map<String, dynamic> json) {
    return RechargePackage(
      id: json['id'] ?? '',
      coins: json['coins'] ?? 0,
      priceUsd: (json['priceUsd'] ?? 0).toDouble(),
    );
  }
}