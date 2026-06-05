import 'package:get/get.dart';
import 'moment_model.dart';

class MomentsController extends GetxController {
  final isLoading = false.obs;
  final posts = <MomentModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadPosts();
  }

  void _loadPosts() async {
    isLoading.value = true;
    // TODO: Fetch from API -> apiService.getMomentsFeed()
    await Future.delayed(const Duration(milliseconds: 1000));

    posts.assignAll([
      MomentModel(
        id: 'post_1',
        userId: 'u1',
        userName: 'Arvind',
        userAvatar: 'https://picsum.photos/seed/a/100',
        content:
            'Having a great time streaming today! Thanks everyone for the gifts 🎁',
        imageUrl: 'https://picsum.photos/seed/post1/600/400',
        likesCount: 124,
        commentsCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      MomentModel(
        id: 'post_2',
        userId: 'u2',
        userName: 'Rahul Star',
        userAvatar: 'https://picsum.photos/seed/b/100',
        content: 'Anyone up for a PK Battle tonight? ⚔️ Drop a comment!',
        likesCount: 45,
        commentsCount: 8,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ]);

    isLoading.value = false;
  }

  void toggleLike(String postId) {
    // TODO: Call API -> apiService.likePost(postId)
  }
}
