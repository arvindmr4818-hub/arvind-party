// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/shop/presentation/bindings/shop_binding.dart
// ARVIND PARTY - SHOP BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/shop_controller.dart';

class ShopBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopController>(() => ShopController());
  }
}