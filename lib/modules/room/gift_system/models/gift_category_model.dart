class GiftCategoryModel {
  final String id;
  final String name; // e.g., 'Popular', 'VIP', 'Luxury', 'Lucky'
  final bool isPremiumOnly;

  const GiftCategoryModel({
    required this.id,
    required this.name,
    this.isPremiumOnly = false,
  });

  factory GiftCategoryModel.fromJson(Map<String, dynamic> json) {
    return GiftCategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      isPremiumOnly: json['isPremiumOnly'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'isPremiumOnly': isPremiumOnly,
    };
  }
}
