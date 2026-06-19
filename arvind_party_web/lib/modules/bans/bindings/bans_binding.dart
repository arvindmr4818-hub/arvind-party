import 'package:get/get.dart';
import '../controllers/bans_controller.dart';

class BansBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BansController>(() => BansController());
  }
}