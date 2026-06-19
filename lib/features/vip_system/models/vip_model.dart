// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/models/vip_model.dart
// ARVIND PARTY - VIP MODEL
// ═══════════════════════════════════════════════════════════════════════════

class VIPTier {
  final String id;
  final String name;
  final double price;
  final int durationDays;
  final List<String> features;
  final String description;
  final VIPBenefits benefits;

  VIPTier({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.features,
    required this.description,
    required this.benefits,
  });

  factory VIPTier.fromJson(Map<String, dynamic> json) {
    return VIPTier(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      durationDays: json['durationDays'] ?? 30,
      features: List<String>.from(json['features'] ?? []),
      description: json['description'] ?? '',
      benefits: VIPBenefits.fromJson(json['benefits'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationDays': durationDays,
      'features': features,
      'description': description,
      'benefits': benefits.toJson(),
    };
  }
}

class VIPBenefits {
  final bool adFree;
  final bool unlimitedRooms;
  final bool premiumWidgets;
  final bool exclusiveFrames;
  final bool exclusiveBatches;
  final bool prioritySupport;
  final bool customProfileFrame;

  VIPBenefits({
    required this.adFree,
    required this.unlimitedRooms,
    required this.premiumWidgets,
    required this.exclusiveFrames,
    required this.exclusiveBatches,
    required this.prioritySupport,
    required this.customProfileFrame,
  });

  factory VIPBenefits.fromJson(Map<String, dynamic> json) {
    return VIPBenefits(
      adFree: json['adFree'] ?? false,
      unlimitedRooms: json['unlimitedRooms'] ?? false,
      premiumWidgets: json['premiumWidgets'] ?? false,
      exclusiveFrames: json['exclusiveFrames'] ?? false,
      exclusiveBatches: json['exclusiveBatches'] ?? false,
      prioritySupport: json['prioritySupport'] ?? false,
      customProfileFrame: json['customProfileFrame'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'adFree': adFree,
      'unlimitedRooms': unlimitedRooms,
      'premiumWidgets': premiumWidgets,
      'exclusiveFrames': exclusiveFrames,
      'exclusiveBatches': exclusiveBatches,
      'prioritySupport': prioritySupport,
      'customProfileFrame': customProfileFrame,
    };
  }
}

class UserVIPStatus {
  final String vipTier;
  final DateTime expiryDate;
  final int daysRemaining;
  final bool isActive;

  UserVIPStatus({
    required this.vipTier,
    required this.expiryDate,
    required this.daysRemaining,
    required this.isActive,
  });

  factory UserVIPStatus.fromJson(Map<String, dynamic> json) {
    return UserVIPStatus(
      vipTier: json['vipTier'] ?? 'free',
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toString()),
      daysRemaining: json['daysRemaining'] ?? 0,
      isActive: json['isActive'] ?? false,
    );
  }
}