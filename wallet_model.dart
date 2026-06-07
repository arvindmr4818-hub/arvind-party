class WalletModel {
  final int coins;
  final int diamonds;

  WalletModel({required this.coins, required this.diamonds});

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      coins: json['coins'] ?? 0,
      diamonds: json['diamonds'] ?? 0,
    );
  }
}