enum SettlementStatus { calculated, approved, escrowed, released }

class AgencySalaryModel {
  final String hostId;
  final String hostName;
  final int coinsEarned;
  final double rawGiftRevenueUSD;
  final double validBroadcastingHours;
  final bool targetAchieved;
  final double calculatedBonusUSD;
  final double finalNetSalaryUSD;
  final SettlementStatus status;
  final String billingCycleId; // e.g., "2026_JUNE_CYCLE"

  const AgencySalaryModel({
    required this.hostId,
    required this.hostName,
    required this.coinsEarned,
    required this.rawGiftRevenueUSD,
    required this.validBroadcastingHours,
    required this.targetAchieved,
    required this.calculatedBonusUSD,
    required this.finalNetSalaryUSD,
    required this.status,
    required this.billingCycleId,
  });

  factory AgencySalaryModel.fromJson(Map<String, dynamic> json) {
    return AgencySalaryModel(
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      coinsEarned: json['coinsEarned'] ?? 0,
      rawGiftRevenueUSD: (json['rawGiftRevenueUSD'] ?? 0.0).toDouble(),
      validBroadcastingHours:
          (json['validBroadcastingHours'] ?? 0.0).toDouble(),
      targetAchieved: json['targetAchieved'] ?? false,
      calculatedBonusUSD: (json['calculatedBonusUSD'] ?? 0.0).toDouble(),
      finalNetSalaryUSD: (json['finalNetSalaryUSD'] ?? 0.0).toDouble(),
      status: SettlementStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => SettlementStatus.calculated,
      ),
      billingCycleId: json['billingCycleId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hostId': hostId,
      'hostName': hostName,
      'coinsEarned': coinsEarned,
      'rawGiftRevenueUSD': rawGiftRevenueUSD,
      'validBroadcastingHours': validBroadcastingHours,
      'targetAchieved': targetAchieved,
      'calculatedBonusUSD': calculatedBonusUSD,
      'finalNetSalaryUSD': finalNetSalaryUSD,
      'status': status.toString().split('.').last,
      'billingCycleId': billingCycleId,
    };
  }
}
