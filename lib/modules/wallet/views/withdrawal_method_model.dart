class WithdrawalMethod {
  final String id;
  final String name;
  final String icon;
  final double minWithdrawalUsd;
  final double feePercentage;
  final String processingTime;

  WithdrawalMethod({
    required this.id,
    required this.name,
    required this.icon,
    required this.minWithdrawalUsd,
    this.feePercentage = 0.0,
    required this.processingTime,
  });
}
