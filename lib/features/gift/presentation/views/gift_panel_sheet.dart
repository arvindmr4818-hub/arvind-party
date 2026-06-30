import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';

class GiftPanelSheet extends StatelessWidget {
  final String roomId;
  final String? targetUserId;
  const GiftPanelSheet({super.key, required this.roomId, this.targetUserId});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<GiftController>();
    ctrl.loadGifts();

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1928),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),

        // Header
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('Send Gift', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            const Spacer(),
            Obx(() => Row(children: [
              const Icon(Icons.monetization_on, color: Color(0xFFFF8906), size: 16),
              const SizedBox(width: 4),
              Text('${ctrl.userCoins.value}', style: const TextStyle(color: Color(0xFFFF8906), fontWeight: FontWeight.bold)),
            ])),
          ])),

        const SizedBox(height: 12),

        // Category tabs
        Obx(() => SizedBox(height: 36, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: ctrl.categories.length,
          itemBuilder: (_, i) {
            final cat = ctrl.categories[i];
            final isSelected = ctrl.selectedCategory.value == cat;
            return GestureDetector(
              onTap: () => ctrl.selectedCategory.value = cat,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF8906) : Colors.white12,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(cat, style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                )),
              ),
            );
          },
        ))),

        const SizedBox(height: 12),

        // Gift grid
        Expanded(child: Obx(() => ctrl.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF8906)))
          : ctrl.gifts.isEmpty
            ? const Center(child: Text('No gifts available', style: TextStyle(color: Colors.white54)))
            : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.8),
                itemCount: ctrl.filteredGifts.length,
                itemBuilder: (_, i) {
                  final gift = ctrl.filteredGifts[i];
                  final isSelected = ctrl.selectedGift.value?['_id'] == gift['_id'];
                  return GestureDetector(
                    onTap: () => ctrl.selectedGift.value = gift,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFFF8906).withOpacity(0.2) : Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? const Color(0xFFFF8906) : Colors.transparent, width: 2),
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        gift['imageUrl'] != null
                          ? Image.network(gift['imageUrl'], width: 44, height: 44, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.card_giftcard, color: Color(0xFFFF8906), size: 36))
                          : const Icon(Icons.card_giftcard, color: Color(0xFFFF8906), size: 36),
                        const SizedBox(height: 4),
                        Text(gift['name'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 10),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          const Icon(Icons.monetization_on, color: Color(0xFFFF8906), size: 10),
                          const SizedBox(width: 2),
                          Text('${gift['price'] ?? 0}', style: const TextStyle(color: Color(0xFFFF8906), fontSize: 10)),
                        ]),
                      ]),
                    ),
                  );
                },
              ))),

        // Send button
        Padding(padding: const EdgeInsets.all(16), child: Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ctrl.selectedGift.value != null ? const Color(0xFFFF8906) : Colors.white24,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: ctrl.selectedGift.value != null
              ? () => ctrl.sendGift(roomId: roomId, targetUserId: targetUserId)
              : null,
            child: ctrl.isSending.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : Text(
                  ctrl.selectedGift.value != null
                    ? 'Send ${ctrl.selectedGift.value!['name']} (${ctrl.selectedGift.value!['price']} coins)'
                    : 'Select a gift',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
          ),
        ))),
      ]),
    );
  }
}
