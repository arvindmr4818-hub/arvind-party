import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shop_controller.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopController());

    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xFF15141F),
        elevation: 0,
        title: const Text('VIP Store',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Column(
        children: [
          // Categories
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildTab(controller, 'frame', 'Frames'),
                    _buildTab(controller, 'mount', 'Mounts (Entry)'),
                    _buildTab(controller, 'bubble', 'Chat Bubbles'),
                  ],
                )),
          ),
          // Items Grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value)
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              if (controller.filteredItems.isEmpty)
                return const Center(
                    child: Text('No items available',
                        style: TextStyle(color: Colors.white54)));

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: controller.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = controller.filteredItems[index];
                  return Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF15141F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag,
                            size: 64, color: Colors.white38), // Placeholder
                        const SizedBox(height: 16),
                        Text(item.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        Text('${item.durationDays} Days',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const Spacer(),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF8906),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                          ),
                          child: GestureDetector(
                            onTap: () => controller.purchaseItem(item),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.diamond,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text('${item.priceDiamonds}',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(ShopController controller, String type, String title) {
    final isSelected = controller.selectedCategory.value == type;
    return GestureDetector(
      onTap: () => controller.changeCategory(type),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF8906) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? const Color(0xFFFF8906) : Colors.white24),
        ),
        alignment: Alignment.center,
        child: Text(title,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}
