enum GiftType { static, animated, svga, mp4, combo }
enum GiftCategory { normal, lucky, festival, vip, room }

class GiftModel {
  final String id;
  final String name;
  final String? description;
  final GiftType type;
  final GiftCategory category;
  final double price;
  final String previewImageUrl;
  final String? animationUrl;
  final int? comboCount;
  final String? comboAnimationUrl;
  final bool isLucky;
  final int? luckyMinCoins;
  final int? luckyMaxCoins;
  final int? requiredVipLevel;
  final String? roomId;
  final bool isAvailable;

  GiftModel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.category,
    required this.price,
    required this.previewImageUrl,
    this.animationUrl,
    this.comboCount,
    this.comboAnimationUrl,
    this.isLucky = false,
    this.luckyMinCoins,
    this.luckyMaxCoins,
    this.requiredVipLevel,
    this.roomId,
    this.isAvailable = true,
  });

  factory GiftModel.fromJson(Map<String, dynamic> json) => GiftModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    description: json['description'],
    type: GiftType.values.firstWhere((e) => e.name == json['type']),
    category: GiftCategory.values.firstWhere((e) => e.name == json['category']),
    price: (json['price'] ?? 0).toDouble(),
    previewImageUrl: json['previewImageUrl'] ?? '',
    animationUrl: json['animationUrl'],
    comboCount: json['comboCount'],
    comboAnimationUrl: json['comboAnimationUrl'],
    isLucky: json['isLucky'] ?? false,
    luckyMinCoins: json['luckyMinCoins'],
    luckyMaxCoins: json['luckyMaxCoins'],
    requiredVipLevel: json['requiredVipLevel'],
    roomId: json['roomId'],
    isAvailable: json['isAvailable'] ?? true,
  );
}

class GiftHistoryModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final GiftModel gift;
  final int quantity;
  final DateTime createdAt;

  GiftHistoryModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.gift,
    required this.quantity,
    required this.createdAt,
  });

  factory GiftHistoryModel.fromJson(Map<String, dynamic> json) => GiftHistoryModel(
    id: json['id'] ?? '',
    senderId: json['senderId'] ?? '',
    senderName: json['senderName'] ?? '',
    receiverId: json['receiverId'] ?? '',
    receiverName: json['receiverName'] ?? '',
    gift: GiftModel.fromJson(json['gift']),
    quantity: json['quantity'] ?? 1,
    createdAt: DateTime.parse(json['createdAt']),
  );
}