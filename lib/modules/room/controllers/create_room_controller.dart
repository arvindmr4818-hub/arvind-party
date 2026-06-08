import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../../../core/services/api_service.dart';

class CreateRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  var isLoading = false.obs;
  var selectedImagePath = ''.obs;

  // 🖼️ Pick Room Cover from Gallery
  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  // 🚀 Upload to Cloudinary and Create Room on Backend
  Future<void> createRoom() async {
    String name = nameController.text.trim();
    
    if (name.isEmpty) {
      Get.snackbar('Required', 'Please enter a room name');
      return;
    }

    if (selectedImagePath.value.isEmpty) {
      Get.snackbar('Required', 'Please select a cover image for the room.');
      return;
    }

    isLoading(true);
    try {
      // Real Cover Upload using Cloudinary
      final cloudinary = CloudinaryPublic('YOUR_CLOUD_NAME', 'YOUR_UPLOAD_PRESET', cache: false);
      
      CloudinaryResponse cloudResponse = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(selectedImagePath.value, folder: 'room_covers'),
      );
      
      String finalCoverUrl = cloudResponse.secureUrl;

      // Connect to Arvind Party Node.js Backend
      await _apiService.post('rooms/create', body: {
        'name': name,
        'coverImage': finalCoverUrl,
      });

      Get.snackbar('Success', 'Live room created successfully! 🎉');
      Get.back(); // Navigate back to the Home/Discover screen
    } catch (e) {
      Get.snackbar('Server Error', 'Failed to create room. Please try again.');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}