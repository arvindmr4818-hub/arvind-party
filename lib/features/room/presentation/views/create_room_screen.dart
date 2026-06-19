import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_room_controller.dart'; // Correct relative import as per your folder tree

class CreateRoomScreen extends StatelessWidget {
  final CreateRoomController controller = Get.put(CreateRoomController());

  CreateRoomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Create Live Room',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. COVER IMAGE UPLOAD CONTAINER ───────────────────────────
            const Text(
              'Room Cover Image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: controller.pickImage,
              child: Obx(() {
                return Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    // FIXED: Replaced legacy withOpacity with clean withValues API
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFC107), width: 1),
                    image: controller.selectedImagePath.value.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(controller.selectedImagePath.value)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: controller.selectedImagePath.value.isEmpty
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: Color(0xFFFFC107),
                              size: 40,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload cover',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        )
                      : null,
                );
              }),
            ),
            const SizedBox(height: 32),

            // ── 2. ROOM INPUT NAME CONTAINER ──────────────────────────────
            const Text(
              'Room Name',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                // FIXED: Replaced legacy withOpacity with clean withValues API
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: TextField(
                controller: controller.nameController,
                style: const TextStyle(color: Colors.white),
                maxLength: 30,
                buildCounter: (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  );
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '', // Prevents double counter rendering bugs
                  hintText: 'e.g., Chill Vibes Only 😎',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 60),

            // ── 3. EXECUTION SUBMIT TRIGGER CONTAINER ───────────────────────
            Obx(() => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.createRoom,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Go Live!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}