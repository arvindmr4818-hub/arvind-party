import 'package:get/get.dart';
import '../controllers/block_controller.dart';

class BlockBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BlockController>(() => BlockController());
  }
}