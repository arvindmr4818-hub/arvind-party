enum GiftAnimationType { none, lottie, svga, rive }

class GiftModel {
  final String id;
  final String name;
  final String icon; // Preview icon asset path or network URL
  final int price; // Coin cost value
  final bool isAnimated;
  final bool isFullScreen;
  final GiftAnimationType animationType;
  final String? animationUrl; // Target path for Lottie/SVGA rendering engine
  final bool isLuckyGift; // Random probability cashout indicator

  const GiftModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.price,
    this.isAnimated = false,
    this.isFullScreen = false,
    this.animationType = GiftAnimationType.none,
    this.animationUrl,
    this.isLuckyGift = false,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) {
    return GiftModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '',
      price: json['price'] ?? 0,
      isAnimated: json['isAnimated'] ?? false,
      isFullScreen: json['isFullScreen'] ?? false,
      animationType: GiftAnimationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['animationType'],
        orElse: () => GiftAnimationType.none,
      ),
      animationUrl: json['animationUrl'],
      isLuckyGift: json['isLuckyGift'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'price': price,
      'isAnimated': isAnimated,
      'isFullScreen': isFullScreen,
      'animationType': animationType.toString().split('.').last,
      'animationUrl': animationUrl,
      'isLuckyGift': isLuckyGift,
    };
  }
}
