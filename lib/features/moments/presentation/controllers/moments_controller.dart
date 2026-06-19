// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/moments/presentation/controllers/moments_controller.dart
// ARVIND PARTY - MOMENTS CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class MomentsController extends GetxController {
  final isLoading = false.obs;
  final posts = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading.value = true;
      // TODO: MomentsRepository().fetchPosts();
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load moments');
    } finally {
      isLoading.value = false;
    }
  }

  void likePost(String postId) {
    // TODO: MomentsRepository().likePost(postId);
  }
}