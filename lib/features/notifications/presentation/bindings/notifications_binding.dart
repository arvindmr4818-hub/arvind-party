// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/notifications/presentation/bindings/notifications_binding.dart
// ARVIND PARTY - NOTIFICATIONS BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}