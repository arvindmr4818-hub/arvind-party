class ShopItemModel {
  final String id;
  final String name;
  final String type; // 'frame', 'mount', 'bubble'
  final int priceDiamonds;
  final int durationDays;

  ShopItemModel({
    required this.id,
    required this.name,
    required this.type,
    required this.priceDiamonds,
    this.durationDays = 7,
  });
}
