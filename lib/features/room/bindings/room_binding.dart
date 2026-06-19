// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/room/bindings/room_binding.dart
// ARVIND PARTY - ROOM BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class RoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomController>(() => RoomController());
  }
}