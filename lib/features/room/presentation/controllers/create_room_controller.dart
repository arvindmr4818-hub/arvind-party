import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/services/api_service.dart';

class CreateRoomController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final isLoading = false.obs;
  final selectedImagePath = ''.obs;

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
      Get.snackbar(
        'Error 🛑', 
        'Failed to pick cover image asset.',
        backgroundColor: const Color(0xFF15141F),
        colorText: Colors.white,
      );
    }
  }

  Future<void> createRoom() async {
    String name = nameController.text.trim();
    
    if (name.isEmpty) {
      Get.snackbar('Required ⚠️', 'Please enter a catchy room name.');
      return;
    }

    try {
      isLoading.value = true;
      
      String finalCoverUrl = '';
      if (selectedImagePath.value.isNotEmpty) {
        final response = await _apiService.uploadFile(
          'uploadroom-cover',
          selectedImagePath.value,
          'cover',
        );
        if (response is Map && response['success'] == true) {
          finalCoverUrl = response['url']?.toString() ?? '';
        }
      }

      final response = await _apiService.post('rooms/create', body: {
        'title': name,
        'banner': finalCoverUrl,
        'seatCount': 8,
      });

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Success 🎉', 
          'Live room created successfully! Going live...',
          backgroundColor: const Color(0xFF15141F),
          colorText: Colors.white,
        );
        
        final String newRoomId = response['data']?['_id'] ?? '';
        
        if (newRoomId.isNotEmpty) {
          Get.offNamed('/room_screen', arguments: {'roomId': newRoomId});
        } else {
          Get.back();
        }
      } else {
        Get.snackbar('Creation Failed 🛑', response?['message'] ?? 'Server refused room registration.');
      }
    } catch (e) {
      debugPrint('Exception inside room creation controller: $e');
      Get.snackbar('Server Error 🛑', 'Failed to push configuration parameters.');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}