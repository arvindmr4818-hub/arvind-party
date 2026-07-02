import 'package:get/get.dart';
import '../controllers/room_controller.dart';
import '../../services/room_service.dart';

class RoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomService>(() => RoomService());
    Get.lazyPut<RoomController>(() => RoomController());
  }
}
