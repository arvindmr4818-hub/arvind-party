// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/chat/bindings/chat_binding.dart
// ARVIND PARTY - CHAT BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(() => ChatController());
  }
}