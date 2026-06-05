class UserLevelInfo {
  final int currentLevel;
  final int currentExp;
  final int nextLevelExp;

  UserLevelInfo({
    required this.currentLevel,
    required this.currentExp,
    required this.nextLevelExp,
  });

  double get progressPercentage => currentExp / nextLevelExp;
}

class AppBadge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final bool isUnlocked;

  AppBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.isUnlocked = false,
  });
}

class AvatarFrame {
  final String id;
  final String name;
  final String imagePath; // URL ya Asset ka path aayega yahan
  final bool isUnlocked;
  final bool isEquipped;

  AvatarFrame({
    required this.id,
    required this.name,
    required this.imagePath,
    this.isUnlocked = false,
    this.isEquipped = false,
  });

  // State update karne ke liye copyWith method
  AvatarFrame copyWith({
    String? id,
    String? name,
    String? imagePath,
    bool? isUnlocked,
    bool? isEquipped,
  }) {
    return AvatarFrame(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isEquipped: isEquipped ?? this.isEquipped,
    );
  }
}
