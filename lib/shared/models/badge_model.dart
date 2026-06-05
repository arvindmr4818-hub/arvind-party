// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/shared/models/badge_model.dart
// ═══════════════════════════════════════════════════════════════════════════

class BadgeModel {
  final String id;
  final String name;
  final String iconUrl;
  final String description;

  BadgeModel({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.description,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconUrl': iconUrl,
      'description': description,
    };
  }
}
