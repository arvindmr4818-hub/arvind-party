class UserModel {
  final String id;
  final String name;
  final String avatar;
  final int level;
  final bool isVip;
  final int followers;
  final int following;

  UserModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.isVip,
    required this.followers,
    required this.following,
  });
}
