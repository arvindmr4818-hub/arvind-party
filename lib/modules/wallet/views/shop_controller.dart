import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'shop_item_model.dart';

class ShopController extends GetxController {
  final isLoading = false.obs;
  final selectedCategory = 'frame'.obs;
  final items = <ShopItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadShopData();
  }

  void _loadShopData() async {
    isLoading.value = true;
    // TODO: Real API call (apiService.getShopItems())
    await Future.delayed(const Duration(milliseconds: 800));

    items.assignAll([
      ShopItemModel(
          id: 's1',
          name: 'Neon Frame',
          type: 'frame',
          priceDiamonds: 500,
          durationDays: 7),
      ShopItemModel(
          id: 's2',
          name: 'Dragon Wings',
          type: 'frame',
          priceDiamonds: 1500,
          durationDays: 30),
      ShopItemModel(
          id: 's3',
          name: 'Ferrari Mount',
          type: 'mount',
          priceDiamonds: 3000,
          durationDays: 7),
      ShopItemModel(
          id: 's4',
          name: 'UFO Mount',
          type: 'mount',
          priceDiamonds: 10000,
          durationDays: 30),
      ShopItemModel(
          id: 's5',
          name: 'Fire Bubble',
          type: 'bubble',
          priceDiamonds: 200,
          durationDays: 7),
    ]);

    isLoading.value = false;
  }

  List<ShopItemModel> get filteredItems =>
      items.where((item) => item.type == selectedCategory.value).toList();

  void changeCategory(String category) {
    selectedCategory.value = category;
  }

  void purchaseItem(ShopItemModel item) {
    // TODO: Call API to deduct diamonds and add item to user inventory
    Get.dialog(AlertDialog(
      backgroundColor: const Color(0xFF15141F),
      title:
          const Text('Purchase Confirm', style: TextStyle(color: Colors.white)),
      content: Text('Buy ${item.name} for ${item.priceDiamonds} diamonds?',
          style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
            onPressed: Get.back,
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white38))),
        TextButton(
          onPressed: () {
            Get.back();
            Get.snackbar('Success', '${item.name} purchased successfully!',
                backgroundColor: Colors.green, colorText: Colors.white);
          },
          child: const Text('Buy Now',
              style: TextStyle(
                  color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
        ),
      ],
    ));
  }
}
