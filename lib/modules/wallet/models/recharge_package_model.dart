class RechargePackage {
  final String id;
  final int diamonds;
  final double price;
  final String currency;
  final int bonus;

  RechargePackage({
    required this.id,
    required this.diamonds,
    required this.price,
    this.currency = 'USD',
    this.bonus = 0,
  });

  double get totalDiamonds => (diamonds + bonus).toDouble();
}
