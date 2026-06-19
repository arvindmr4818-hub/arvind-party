// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/shop/presentation/views/shop_screen.dart
// ARVIND PARTY - SHOP SCREEN
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shop_controller.dart';

class ShopScreen extends GetView<ShopController> {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.shopItems.length,
          itemBuilder: (context, index) {
            final item = controller.shopItems[index];
            return Card(
              color: const Color(0xFF1A1A2E),
              child: ListTile(
                title: Text(item['name'] ?? ''),
                subtitle: Text('${item['price']} ${item['currency']}'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Buy'),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}