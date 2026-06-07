// lib/shared/models/withdrawal_method_model.dart
class WithdrawalMethod {
  final String id;
  final String name; // 'UPI', 'Bank Transfer', 'PayPal', 'Paytm'
  final String iconUrl;
  final int minAmount;
  final int maxAmount;
  final double feePercent;
  final bool isActive;
  final List<String> requiredFields;

  WithdrawalMethod({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.minAmount,
    required this.maxAmount,
    required this.feePercent,
    required this.isActive,
    required this.requiredFields,
  });

  factory WithdrawalMethod.fromJson(Map<String, dynamic> json) {
    return WithdrawalMethod(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'UPI',
      iconUrl: json['iconUrl']?.toString() ?? '',
      minAmount: json['minAmount'] is int ? json['minAmount'] : int.tryParse(json['minAmount']?.toString() ?? '100') ?? 100,
      maxAmount: json['maxAmount'] is int ? json['maxAmount'] : int.tryParse(json['maxAmount']?.toString() ?? '100000') ?? 100000,
      feePercent: (json['feePercent'] is num ? json['feePercent'] : double.tryParse(json['feePercent']?.toString() ?? '0') ?? 0).toDouble(),
      isActive: json['isActive'] is bool ? json['isActive'] : true,
      requiredFields: (json['requiredFields'] is List) ? List<String>.from(json['requiredFields'].map((e) => e.toString())) : const <String>[],
    );
  }
}
