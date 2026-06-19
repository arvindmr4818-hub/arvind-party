import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';
import '../models/gift_model.dart';
import '../widgets/gift_card.dart';
import '../widgets/gift_picker_dialog.dart';

class GiftScreen extends GetView<GiftController> {
  const GiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(GiftController());
    return Scaffold(
      appBar: AppBar(title: const Text('Gift Shop', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
        actions: [Obx(() => Padding(padding: const EdgeInsets.only(right: 16), child: Row(children: [const Icon(Icons.monetization_on, color: Colors.orange), Text(' ${controller.balance.value.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold))])))],
      ),
      body: Column(children: [
        Container(padding: const EdgeInsets.symmetric(vertical: 8), color: Colors.white,
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [FilterChip(label: const Text('All'), selected: controller.selectedCategory.value == null, onSelected: (_) => controller.filterByCategory(null)), ...GiftCategory.values.map((cat) => Padding(padding: const EdgeInsets.only(left: 6), child: FilterChip(label: Text(cat.name), selected: controller.selectedCategory.value == cat, onSelected: (_) => controller.filterByCategory(cat)))).toList()]),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
            if (controller.filteredGifts.isEmpty) return const Center(child: Text('No gifts found in this category', style: TextStyle(color: Colors.grey)));
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.75, mainAxisSpacing: 12, crossAxisSpacing: 12),
              itemCount: controller.filteredGifts.length,
              itemBuilder: (context, index) => GiftCard(gift: controller.filteredGifts[index], onTap: () {
                Get.dialog(GiftPickerDialog(receiverId: 'demo_user_id', receiverName: 'Demo User', roomId: Get.arguments?['roomId']));
              }),
            );
          }),
        ),
      ]),
    );
  }
}