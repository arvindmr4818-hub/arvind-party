class GiftTransactionModel {
  final String id;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String giftId;
  final String giftName;
  final int totalCoins;
  final int comboMultiplier;
  final DateTime timestamp;
  final Map<String, dynamic>? revenueDistribution; // Split tracking logs

  const GiftTransactionModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.giftId,
    required this.giftName,
    required this.totalCoins,
    required this.comboMultiplier,
    required this.timestamp,
    this.revenueDistribution,
  });

  factory GiftTransactionModel.fromJson(Map<String, dynamic> json) {
    return GiftTransactionModel(
      id: json['_id'] ?? json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      receiverId: json['receiverId'] ?? '',
      receiverName: json['receiverName'] ?? '',
      giftId: json['giftId'] ?? '',
      giftName: json['giftName'] ?? '',
      totalCoins: json['totalCoins'] ?? 0,
      comboMultiplier: json['comboMultiplier'] ?? 1,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      revenueDistribution: json['revenueDistribution'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'giftId': giftId,
      'giftName': giftName,
      'totalCoins': totalCoins,
      'comboMultiplier': comboMultiplier,
      'timestamp': timestamp.toIso8601String(),
      'revenueDistribution': revenueDistribution,
    };
  }
}
