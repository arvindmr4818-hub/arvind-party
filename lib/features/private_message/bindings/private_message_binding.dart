import 'package:get/get.dart';
import '../controllers/private_message_controller.dart';

class PrivateMessageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivateMessageController>(
      () => PrivateMessageController(),
      fenix: true,
    );
    Get.lazyPut<UserStatusController>(
      () => UserStatusController(),
      fenix: true,
    );
  }
}