class UserProfileModel {
  final String id;
  final String name;
  final String avatar;
  final int level;
  final bool isVip;
  final String frameUrl;
  final List<String> badges;
  final int followers;
  final int following;
  final int visitors;

  UserProfileModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.isVip,
    required this.frameUrl,
    required this.badges,
    required this.followers,
    required this.following,
    required this.visitors,
  });
}
