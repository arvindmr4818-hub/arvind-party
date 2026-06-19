import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_stats.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      init: ProfileController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Get.toNamed('/settings'),
              ),
            ],
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final profile = controller.myProfile.value;
            if (profile == null) {
              return const Center(child: Text('Profile not found'));
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeader(
                    profile: profile,
                    isMyProfile: true,
                    onEditPressed: () => Get.toNamed(
                      '/edit-profile',
                      arguments: profile,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ProfileStats(
                    followers: profile.followersCount,
                    following: profile.followingCount,
                    posts: profile.postsCount,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Interests',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: profile.interests
                              .map((interest) => Chip(label: Text(interest)))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}