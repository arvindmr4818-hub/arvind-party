import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class OtherProfileScreen extends StatefulWidget {
  final String userId;

  const OtherProfileScreen({super.key, required this.userId});

  @override
  State<OtherProfileScreen> createState() => _OtherProfileScreenState();
}

class _OtherProfileScreenState extends State<OtherProfileScreen> {
  late OtherUserController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtherUserController>();
    controller.fetchUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OtherUserController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = controller.userProfile.value;
            if (profile == null) {
              return const Center(child: Text('Profile not found'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    profile: profile,
                    isMyProfile: false,
                    isFollowing: controller.isFollowing.value,
                    onFollowPressed: () {
                      if (controller.isFollowing.value) {
                        controller.unfollowUser(profile.userId);
                      } else {
                        controller.followUser(profile.userId);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ProfileStats(
                    followers: profile.followersCount,
                    following: profile.followingCount,
                    posts: profile.postsCount,
                    onFollowersPressed: () {
                      controller.fetchFollowers(profile.userId);
                      // Show followers list
                    },
                    onFollowingPressed: () {
                      controller.fetchFollowing(profile.userId);
                      // Show following list
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}