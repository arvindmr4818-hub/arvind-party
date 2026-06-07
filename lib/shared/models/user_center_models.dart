// lib/shared/models/user_center_models.dart
class UserLevelInfo {
  final int level;
  final String title;
  final int currentXp;
  final int nextLevelXp;
  final int totalXp;

  UserLevelInfo({
    required this.level,
    required this.title,
    required this.currentXp,
    required this.nextLevelXp,
    required this.totalXp,
  });

  double get progress {
    if (nextLevelXp <= 0) return 0.0;
    return (currentXp / nextLevelXp).clamp(0.0, 1.0);
  }

  factory UserLevelInfo.fromJson(Map<String, dynamic> json) {
    return UserLevelInfo(
      level: json['level'] is int ? json['level'] : int.tryParse(json['level']?.toString() ?? '1') ?? 1,
      title: json['title']?.toString() ?? 'Newbie',
      currentXp: json['currentXp'] is int ? json['currentXp'] : int.tryParse(json['currentXp']?.toString() ?? '0') ?? 0,
      nextLevelXp: json['nextLevelXp'] is int ? json['nextLevelXp'] : int.tryParse(json['nextLevelXp']?.toString() ?? '100') ?? 100,
      totalXp: json['totalXp'] is int ? json['totalXp'] : int.tryParse(json['totalXp']?.toString() ?? '0') ?? 0,
    );
  }

  UserLevelInfo copyWith({int? level, String? title, int? currentXp, int? nextLevelXp, int? totalXp}) {
    return UserLevelInfo(
      level: level ?? this.level,
      title: title ?? this.title,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      totalXp: totalXp ?? this.totalXp,
    );
  }
}

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
  final DateTime? unlockedAt;

  AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.rarity,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  factory AppBadge.fromJson(Map<String, dynamic> json) {
    return AppBadge(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString() ?? '',
      rarity: json['rarity']?.toString() ?? 'common',
      unlockedAt: json['unlockedAt'] != null ? DateTime.tryParse(json['unlockedAt'].toString()) : null,
    );
  }
}

class AvatarFrame {
  final String id;
  final String name;
  final String imageUrl;
  final int priceCoins;
  final bool isVipOnly;
  final bool isOwned;
  final bool isEquipped;

  AvatarFrame({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.priceCoins,
    required this.isVipOnly,
    required this.isOwned,
    required this.isEquipped,
  });

  AvatarFrame copyWith({bool? isOwned, bool? isEquipped}) {
    return AvatarFrame(
      id: id,
      name: name,
      imageUrl: imageUrl,
      priceCoins: priceCoins,
      isVipOnly: isVipOnly,
      isOwned: isOwned ?? this.isOwned,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }

  factory AvatarFrame.fromJson(Map<String, dynamic> json) {
    return AvatarFrame(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      priceCoins: json['priceCoins'] is int ? json['priceCoins'] : int.tryParse(json['priceCoins']?.toString() ?? '0') ?? 0,
      isVipOnly: json['isVipOnly'] is bool ? json['isVipOnly'] : false,
      isOwned: json['isOwned'] is bool ? json['isOwned'] : false,
      isEquipped: json['isEquipped'] is bool ? json['isEquipped'] : false,
    );
  }
}
