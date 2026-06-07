// lib/core/network/shop_binding.dart
import 'package:get/get.dart';
import '../../modules/wallet/views/shop_controller.dart';

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopController>(() => ShopController());
  }
}
