import 'package:intl/intl.dart';

class UserProfile {
  final String userId;
  final String username;
  final String? nickname;
  final String? bio;
  final String? avatar;
  final String? coverImage;
  final String? gender; // male, female, other, prefer_not-to-say
  final String? country;
  final String? language;
  final DateTime? birthday;
  final bool isVerified;
  final String? verificationBadge; // verified, official, creator, etc.
  final String? vipTier; // free, vip1, vip5, vip10, vip15, svip10, svip15
  final bool isOnline;
  final DateTime? lastSeenAt;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isBlocked;
  final bool isPrivate;
  final String? website;
  final List<String> interests;

  UserProfile({
    required this.userId,
    required this.username,
    this.nickname,
    this.bio,
    this.avatar,
    this.coverImage,
    this.gender,
    this.country,
    this.language,
    this.birthday,
    this.isVerified = false,
    this.verificationBadge,
    this.vipTier = 'free',
    this.isOnline = false,
    this.lastSeenAt,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.followers = const [],
    this.following = const [],
    required this.createdAt,
    this.updatedAt,
    this.isBlocked = false,
    this.isPrivate = false,
    this.website,
    this.interests = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['_id'] ?? json['userId'] ?? '',
      username: json['username'] ?? '',
      nickname: json['nickname'],
      bio: json['bio'],
      avatar: json['avatar'],
      coverImage: json['coverImage'],
      gender: json['gender'],
      country: json['country'],
      language: json['language'],
      birthday:
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      isVerified: json['isVerified'] ?? false,
      verificationBadge: json['verificationBadge'],
      vipTier: json['vipTier'] ?? 'free',
      isOnline: json['isOnline'] ?? false,
      lastSeenAt: json['lastSeenAt'] != null
          ? DateTime.parse(json['lastSeenAt'])
          : null,
      followersCount: json['followersCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      isBlocked: json['isBlocked'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      website: json['website'],
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'nickname': nickname,
      'bio': bio,
      'avatar': avatar,
      'coverImage': coverImage,
      'gender': gender,
      'country': country,
      'language': language,
      'birthday': birthday?.toIso8601String(),
      'website': website,
      'interests': interests,
    };
  }

  String getDisplayName() {
    return nickname?.isNotEmpty == true ? nickname! : username;
  }

  String getAgeFromBirthday() {
    if (birthday == null) return 'N/A';
    final today = DateTime.now();
    int age = today.year - birthday!.year;
    if (today.month < birthday!.month ||
        (today.month == birthday!.month && today.day < birthday!.day)) {
      age--;
    }
    return age.toString();
  }

  String getFormattedBirthday() {
    if (birthday == null) return 'Not provided';
    return DateFormat('MMM dd, yyyy').format(birthday!);
  }

  String getAccountAge() {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return '1 day ago';
    if (difference.inDays < 30) return '${difference.inDays} days ago';
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    }
    return '${(difference.inDays / 365).floor()} years ago';
  }

  bool get isFollowedByMe => followers.contains('current_user_id');

  bool get isFollowingMe => following.contains('current_user_id');
}

class ProfileStats {
  final int followers;
  final int following;
  final int posts;
  final int likes;
  final int views;

  ProfileStats({
    required this.followers,
    required this.following,
    required this.posts,
    this.likes = 0,
    this.views = 0,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
      posts: json['posts'] ?? 0,
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
    );
  }
}
