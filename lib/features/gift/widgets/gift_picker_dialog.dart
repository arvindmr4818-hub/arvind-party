import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/gift_model.dart';
import '../controllers/gift_controller.dart';

class GiftPickerDialog extends GetView<GiftController> {
  final String receiverId;
  final String receiverName;
  final String? roomId;

  const GiftPickerDialog({super.key, required this.receiverId, required this.receiverName, this.roomId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        height: 500,
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Send Gift to $receiverName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
          ]),
          const Divider(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              FilterChip(label: const Text('All'), selected: controller.selectedCategory.value == null, onSelected: (_) => controller.filterByCategory(null)),
              ...GiftCategory.values.map((cat) => Padding(
                padding: const EdgeInsets.only(left: 6),
                child: FilterChip(label: Text(cat.name), selected: controller.selectedCategory.value == cat, onSelected: (_) => controller.filterByCategory(cat)),
              )).toList(),
            ]),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.8, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: controller.filteredGifts.length,
                itemBuilder: (context, index) {
                  final gift = controller.filteredGifts[index];
                  return GestureDetector(
                    onTap: () => _confirmSend(context, gift),
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                      child: Column(children: [
                        Expanded(child: Image.network(gift.previewImageUrl, fit: BoxFit.cover)),
                        Text(gift.name, style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${gift.price.toInt()} 🪙', style: const TextStyle(fontSize: 10, color: Colors.orange)),
                      ]),
                    ),
                  );
                },
              );
            }),
          ),
        ]),
      ),
    );
  }

  void _confirmSend(BuildContext context, GiftModel gift) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Send ${gift.name}?'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('This will cost ${gift.price.toInt()} coins.'),
          if (gift.comboCount != null) Text('Combo: ${gift.comboCount}x'),
          if (gift.isLucky) Text('Lucky gift! You might get coins back!'),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
              controller.sendGift(receiverId, gift, quantity: gift.comboCount ?? 1, roomId: roomId);
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}