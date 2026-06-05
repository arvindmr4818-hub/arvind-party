// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/shared/models/frame_model.dart
// ═══════════════════════════════════════════════════════════════════════════

class FrameModel {
  final String id;
  final String name;
  final String url;
  final String? entryEffectUrl; // E.g., for SVGA or Lottie entry animations

  FrameModel({
    required this.id,
    required this.name,
    required this.url,
    this.entryEffectUrl,
  });

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      entryEffectUrl: json['entryEffectUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'entryEffectUrl': entryEffectUrl,
    };
  }
}
