// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/models/home_model.dart
// ARVIND PARTY - HOME MODELS (Banner, Category, RoomItem)
// ═══════════════════════════════════════════════════════════════════════════

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String? actionLink;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.actionLink,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      title: json['title'] ?? '',
      actionLink: json['actionLink'],
    );
  }
}

class CategoryModel {
  final String id;
  final String name;
  final String iconUrl;
  final String colorHex;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.colorHex,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      colorHex: json['colorHex'] ?? '#FF6B6B',
    );
  }
}

class HomeRoomItem {
  final String id;
  final String name;
  final String? imageUrl;
  final int memberCount;
  final String type; // e.g., 'recommended', 'trending', etc.
  final String? hostName;

  HomeRoomItem({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.memberCount,
    required this.type,
    this.hostName,
  });

  factory HomeRoomItem.fromJson(Map<String, dynamic> json) {
    return HomeRoomItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      memberCount: json['memberCount'] ?? 0,
      type: json['type'] ?? 'recommended',
      hostName: json['hostName'],
    );
  }
}