import 'package:get/get.dart';
import '../controllers/coin_generation_controller.dart';

class SystemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoinGenerationController>(() => CoinGenerationController());
  }
}