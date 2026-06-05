class SearchResultModel {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String type; // 'user' or 'room'
  final bool isFollowing;

  SearchResultModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    this.isFollowing = false,
  });
}
