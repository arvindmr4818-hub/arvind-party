// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/moments/presentation/views/create_post_screen.dart
// ARVIND PARTY - CREATE POST SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/moments_controller.dart';

class CreatePostScreen extends GetView<MomentsController> {
  CreatePostScreen({super.key});

  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: MomentsRepository().createPost(_contentController.text);
              Get.back();
              Get.snackbar('Success', 'Post created');
            },
            child: const Text('Post', style: TextStyle(color: Color(0xFFFF8906))),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _contentController,
          maxLines: 10,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "What's on your mind?",
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFF2D2D44),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }
}