// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/shop/presentation/controllers/shop_controller.dart
// ARVIND PARTY - SHOP CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';

class ShopController extends GetxController {
  final isLoading = false.obs;
  final shopItems = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchShopItems();
  }

  Future<void> fetchShopItems() async {
    try {
      isLoading.value = true;
      // TODO: ShopRepository().fetchItems();
      await Future.delayed(const Duration(milliseconds: 500));
      shopItems.assignAll([
        {'id': '1', 'name': 'Gold Coin', 'price': 100, 'currency': 'coins'},
        {'id': '2', 'name': 'Diamond', 'price': 500, 'currency': 'coins'},
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load shop items');
    } finally {
      isLoading.value = false;
    }
  }
}