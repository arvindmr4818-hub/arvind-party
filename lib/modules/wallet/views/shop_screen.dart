import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/shop_controller.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ FIX 1: Safely inject & initialize controller instance
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
          // Categories Scrollbar Stream
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildTab(controller, 'all', 'All Items'),
                    _buildTab(controller, 'frame', 'Frames'),
                    _buildTab(controller, 'badge', 'Badges'),
                    _buildTab(controller, 'gift', 'Gifts'),
                    _buildTab(controller, 'vip', 'VIP Membership'),
                  ],
                )),
          ),
          
          // Real-Time Items Grid Layout
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF8906)));
              }
              
              final displayItems = controller.filteredItems;

              if (displayItems.isEmpty) {
                return const Center(
                    child: Text('No store modules available in this category',
                        style: TextStyle(color: Colors.white54)));
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75, // Optimized ratio to prevent dynamic layout text overflows
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16),
                itemCount: displayItems.length,
                itemBuilder: (context, index) {
                  final item = displayItems[index];
                  
                  return Container(
                    decoration: BoxDecoration(
                        color: const Color(0xFF15141F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),
                        // Real Backend Image Renderer
                        Expanded(
                          child: item.imageUrl.isNotEmpty
                              ? Image.network(item.imageUrl, fit: BoxFit.contain)
                              : const Icon(Icons.workspace_premium, size: 54, color: Colors.white24),
                        ),
                        const SizedBox(height: 8),
                        Text(item.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('${item.durationDays} Days Validity',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                        const SizedBox(height: 8),
                        
                        // Transaction Action Button Box
                        InkWell(
                          // ✅ FIX 2: Mapped perfectly to controller.purchase execution model
                          onTap: () => controller.purchase(item),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: item.isOwned ? Colors.white10 : const Color(0xFFFF8906),
                              borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(15)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.priceDiamonds > 0 ? Icons.diamond : Icons.monetization_on,
                                  color: item.isOwned ? Colors.white38 : Colors.white, 
                                  size: 14
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  item.isOwned 
                                      ? 'OWNED' 
                                      : '${item.priceDiamonds > 0 ? item.priceDiamonds : item.priceCoins}',
                                  style: TextStyle(
                                      color: item.isOwned ? Colors.white38 : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
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
    return Obx(() {
      final isSelected = controller.selectedCategory.value == type;
      return GestureDetector(
        // ✅ FIX 3: Mapped seamlessly with controller.selectCategory interface
        onTap: () => controller.selectCategory(type),
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      );
    });
  }
}