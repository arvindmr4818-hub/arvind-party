import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/views/api_service.dart';

class CompleteProfileController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  var isLoading = false.obs;
  var uploadedAvatarUrl = ''.obs;
  var selectedImagePath = ''.obs;

  // Pick Avatar from Gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  // Send Real Data to the Arvind Party Backend
  Future<void> submitProfile() async {
    String name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter your name');
      return;
    }

    isLoading(true);
    try {
      // Real Avatar Upload using Cloudinary
      String finalAvatarUrl = uploadedAvatarUrl.value;
      
      if (selectedImagePath.value.isNotEmpty) {
        // Make sure to replace these keys with your real Cloudinary credentials!
        final cloudinary = CloudinaryPublic('YOUR_CLOUD_NAME', 'YOUR_UPLOAD_PRESET', cache: false);
        
        CloudinaryResponse cloudResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(selectedImagePath.value, folder: 'avatars'),
        );
        
        finalAvatarUrl = cloudResponse.secureUrl;
        uploadedAvatarUrl.value = finalAvatarUrl;
      }

      var response = await _apiService.post('users/complete-profile', {
        'name': name,
        'avatar': finalAvatarUrl,
      });

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Profile updated successfully!');
        Get.offAllNamed('/home'); // Navigate to the Discovery Home screen!
      } else {
        Get.snackbar('Error', 'Could not update profile');
      }
    } catch (e) {
      Get.snackbar('Server Error', 'Failed to connect to servers.');
    } finally {
      isLoading(false);
    }
  }
}
