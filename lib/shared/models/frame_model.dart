class FrameModel {
  final String id;
  final String name;
  final String imageUrl;
  final int priceCoins;
  final int validityDays;
  final bool isVipOnly;

  FrameModel({required this.id, required this.name, required this.imageUrl, required this.priceCoins, required this.validityDays, required this.isVipOnly});

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown Frame',
      imageUrl: json['imageUrl'] ?? '',
      priceCoins: json['priceCoins'] ?? 0,
      validityDays: json['validityDays'] ?? 30,
      isVipOnly: json['isVipOnly'] ?? false,
    );
  }
}