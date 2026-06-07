// lib/shared/models/wallet_model.dart
class WalletModel {
  final String userId;
  final int coins;
  final int diamonds;
  final int pendingCoins;
  final int totalEarned;
  final int totalSpent;
  final DateTime updatedAt;

  WalletModel({
    required this.userId,
    required this.coins,
    required this.diamonds,
    required this.pendingCoins,
    required this.totalEarned,
    required this.totalSpent,
    required this.updatedAt,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      userId: json['userId']?.toString() ?? '',
      coins: json['coins'] is int ? json['coins'] : int.tryParse(json['coins']?.toString() ?? '0') ?? 0,
      diamonds: json['diamonds'] is int ? json['diamonds'] : int.tryParse(json['diamonds']?.toString() ?? '0') ?? 0,
      pendingCoins: json['pendingCoins'] is int ? json['pendingCoins'] : int.tryParse(json['pendingCoins']?.toString() ?? '0') ?? 0,
      totalEarned: json['totalEarned'] is int ? json['totalEarned'] : int.tryParse(json['totalEarned']?.toString() ?? '0') ?? 0,
      totalSpent: json['totalSpent'] is int ? json['totalSpent'] : int.tryParse(json['totalSpent']?.toString() ?? '0') ?? 0,
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'coins': coins,
        'diamonds': diamonds,
        'pendingCoins': pendingCoins,
        'totalEarned': totalEarned,
        'totalSpent': totalSpent,
        'updatedAt': updatedAt.toIso8601String(),
      };

  WalletModel copyWith({int? coins, int? diamonds, int? pendingCoins, int? totalEarned, int? totalSpent}) {
    return WalletModel(
      userId: userId,
      coins: coins ?? this.coins,
      diamonds: diamonds ?? this.diamonds,
      pendingCoins: pendingCoins ?? this.pendingCoins,
      totalEarned: totalEarned ?? this.totalEarned,
      totalSpent: totalSpent ?? this.totalSpent,
      updatedAt: DateTime.now(),
    );
  }
}
