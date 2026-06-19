import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gifts_controller.dart';
import '../../../core/theme/web_theme.dart';
import '../../../shared/widgets/admin_scaffold.dart';

class GiftsView extends GetView<GiftsController> {
  const GiftsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Gift Management',
      actions: [
        IconButton(
          icon: const Icon(Icons.add, color: WebTheme.primaryOrange),
          onPressed: () => _showAddGiftDialog(context),
          tooltip: 'Add Gift',
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: WebTheme.textSecondary),
          onPressed: () => controller.loadGifts(),
          tooltip: 'Refresh',
        ),
      ],
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.gifts.isEmpty) {
          return const Center(
            child: Text(
              'No gifts found',
              style: TextStyle(color: WebTheme.textSecondary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 900
                  ? 4
                  : constraints.maxWidth > 600
                      ? 3
                      : 2;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1,
                ),
                itemCount: controller.gifts.length,
                itemBuilder: (context, index) {
                  final gift = controller.gifts[index];
                  final name = gift['name']?.toString() ?? 'Unknown Gift';
                  final price = gift['price']?.toString() ?? '0';
                  final category = gift['category']?.toString() ?? 'General';
                  final giftId = gift['id']?.toString() ?? '';

                  return Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: WebTheme.primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.card_giftcard,
                            size: 32,
                            color: WebTheme.primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            color: WebTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹$price',
                          style: const TextStyle(
                            color: WebTheme.primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          category,
                          style: const TextStyle(
                            color: WebTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _confirmDeleteGift(giftId, name),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: WebTheme.errorRed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              minimumSize: Size.zero,
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            child: const Text('Remove'),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  void _showAddGiftDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final categoryCtrl = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Gift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Gift Name',
                hintText: 'Enter gift name',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(
                labelText: 'Price',
                hintText: 'Enter price in coins',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: categoryCtrl,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Flowers, Vehicles, etc.',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty &&
                  priceCtrl.text.trim().isNotEmpty) {
                controller.addGift({
                  'name': nameCtrl.text.trim(),
                  'price': priceCtrl.text.trim(),
                  'category': categoryCtrl.text.trim().isNotEmpty
                      ? categoryCtrl.text.trim()
                      : 'General',
                });
                Get.back();
              }
            },
            child: const Text('Add Gift'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGift(String giftId, String giftName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Gift'),
        content: Text('Are you sure you want to delete "$giftName"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteGift(giftId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WebTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}