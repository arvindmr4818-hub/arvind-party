// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/modules/room/bindings/room_binding.dart
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../controllers/create_room_controller.dart';

class RoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomController>(() => RoomController());
  }
}

class CreateRoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateRoomController>(() => CreateRoomController());
  }
}
