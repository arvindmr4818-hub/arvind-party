import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';
import '../widgets/gift_card.dart';
import '../widgets/gift_category_tab.dart';
import '../widgets/combo_counter_widget.dart';

class GiftStoreBottomSheet extends StatelessWidget {
  const GiftStoreBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Locate the current scope active controller dependency instance
    final GiftController controller = Get.put(GiftController());

    return Container(
      height: 440,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff15141F), // Dark glass layout background canvas
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Top Core Navigation & Target Metrics Info Header Strip
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() => Text(
                        "Send to: ${controller.targetReceiverName.value}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      )),

                  // Live Dynamic Coins Vault Tracker Indicator
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withOpacity(0.2), width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const Text("🪙 ", style: TextStyle(fontSize: 12)),
                        Obx(() => Text(
                              "${controller.userWalletBalance.value}",
                              style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Divider(color: Colors.white.withOpacity(0.04), height: 1),

            // 2. Categories Scroll Tape Tabs Section
            Container(
              height: 44,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.giftCategories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final cat = controller.giftCategories[index];
                      return GiftCategoryTab(
                        category: cat,
                        isSelected:
                            controller.selectedCategoryId.value == cat.id,
                        onTap: () => controller.loadCategoryGifts(cat.id),
                      );
                    },
                  )),
            ),

            // 3. Central Grid Selection Matrix Sheet
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Obx(() {
                  if (controller.activeGiftsList.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xffFF8906)));
                  }

                  return GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          4, // Symmetric grid structures spacing parameters
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: controller.activeGiftsList.length,
                    itemBuilder: (context, index) {
                      final item = controller.activeGiftsList[index];
                      return Obx(() => GiftCard(
                            gift: item,
                            isSelected:
                                controller.selectedGiftId.value == item.id,
                            onTap: () => controller.selectGiftItem(item.id),
                          ));
                    },
                  );
                }),
              ),
            ),

            // 4. Operational Execution Trigger Footer Panel (Combo System Integrated)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xff0F0E17),
                border:
                    Border.all(color: Colors.white.withOpacity(0.02), width: 1),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Select multipliers for combo fire stream animations cascade effects",
                      style: TextStyle(
                          color: Colors.white38, fontSize: 10, height: 1.3),
                    ),
                  ),

                  // Interactive Floating Combo Engine Module Injected
                  const ComboCounterWidget(),
                  const SizedBox(width: 12),

                  // Absolute Execution Button
                  Obx(() {
                    bool hasSelection =
                        controller.selectedGiftId.value.isNotEmpty;
                    return SizedBox(
                      height: 38,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasSelection
                              ? const Color(0xffFF8906)
                              : Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(19)),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: hasSelection
                            ? () => controller.executeSingleGiftDispatch()
                            : null,
                        child: const Text(
                          "Send 🎁",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
