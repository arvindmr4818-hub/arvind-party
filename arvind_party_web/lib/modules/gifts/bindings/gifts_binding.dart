import 'package:get/get.dart';
import '../controllers/gifts_controller.dart';

class GiftsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GiftsController>(() => GiftsController());
  }
}