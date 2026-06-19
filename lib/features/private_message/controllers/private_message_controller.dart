import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/private_message_model.dart';
import '../repositories/private_message_repository.dart';

class PrivateMessageController extends GetxController {
  final messageRepository = PrivateMessageRepository();
  final storage = GetStorage();

  var privateChats = <PrivateChatUser>[].obs;
  var messages = <PrivateMessage>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var recipientTypingStatus = false.obs;
  var selectedMessage = Rxn<PrivateMessage>();

  @override
  void onInit() {
    super.onInit();
    fetchPrivateChats();
    setOnlineStatus(true);
  }

  @override
  void onClose() {
    setOnlineStatus(false);
    super.onClose();
  }

  void fetchPrivateChats() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final chats = await messageRepository.getPrivateChats();
      privateChats.value = chats;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void fetchMessages(String userId) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final msgs = await messageRepository.getPrivateMessages(userId);
      messages.value = msgs;

      markAllAsRead(userId);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void sendMessage({
    required String recipientId,
    required String content,
  }) async {
    try {
      final message = await messageRepository.sendMessage(
        recipientId: recipientId,
        content: content,
        messageType: 'text',
      );
      messages.add(message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void sendImage(String recipientId, String filePath) async {
    isLoading.value = true;
    try {
      final message = await messageRepository.uploadMedia(
        recipientId: recipientId,
        filePath: filePath,
        messageType: 'image',
      );
      messages.add(message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void sendVideo(String recipientId, String filePath) async {
    isLoading.value = true;
    try {
      final message = await messageRepository.uploadMedia(
        recipientId: recipientId,
        filePath: filePath,
        messageType: 'video',
      );
      messages.add(message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void sendVoice(String recipientId, String filePath) async {
    isLoading.value = true;
    try {
      final message = await messageRepository.uploadMedia(
        recipientId: recipientId,
        filePath: filePath,
        messageType: 'voice',
      );
      messages.add(message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void sendFile(String recipientId, String filePath) async {
    isLoading.value = true;
    try {
      final message = await messageRepository.uploadMedia(
        recipientId: recipientId,
        filePath: filePath,
        messageType: 'file',
      );
      messages.add(message);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void deleteMessage(String messageId) async {
    try {
      await messageRepository.deleteMessage(messageId);
      messages.removeWhere((m) => m.id == messageId);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void editMessage({
    required String messageId,
    required String newContent,
  }) async {
    try {
      await messageRepository.editMessage(
        messageId: messageId,
        newContent: newContent,
      );

      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        messages.refresh();
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  void markAllAsRead(String userId) async {
    try {
      await messageRepository.markAllAsRead(userId);
    } catch (e) {
      // Error handling silently
    }
  }

  void setTypingStatus(String userId, bool isTyping) async {
    try {
      await messageRepository.setTypingStatus(userId, isTyping);
    } catch (e) {
      // Error handling silently
    }
  }

  void setOnlineStatus(bool isOnline) async {
    try {
      await messageRepository.setOnlineStatus(isOnline);
    } catch (e) {
      // Error handling silently
    }
  }

  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String formatDuration(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).toInt());
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

class UserStatusController extends GetxController {
  final messageRepository = PrivateMessageRepository();

  var userStatus = Rxn<UserStatus>();
  var isOnline = false.obs;

  void fetchUserStatus(String userId) async {
    try {
      final status = await messageRepository.getUserStatus(userId);
      userStatus.value = status;
      isOnline.value = status.isOnline;
    } catch (e) {
      // Error handling silently
    }
  }

  void setTypingStatus(String userId, bool isTyping) async {
    try {
      await messageRepository.setTypingStatus(userId, isTyping);
    } catch (e) {
      // Error handling silently
    }
  }
}