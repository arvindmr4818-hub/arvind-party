class VipModel {
  final bool isVip;
  final int level;
  final DateTime? expiryDate;
  final List<String> perks;

  VipModel({
    required this.isVip,
    required this.level,
    this.expiryDate,
    required this.perks,
  });

  factory VipModel.fromJson(Map<String, dynamic> json) {
    return VipModel(
      isVip: json['isVip'] ?? false,
      level: json['level'] ?? 0,
      expiryDate:
          json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
      perks: List<String>.from(json['perks'] ?? []),
    );
  }
}