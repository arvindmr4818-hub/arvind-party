// arvind_party_web/lib/modules/gifts/views/gifts_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/admin_api.dart';
import '../../../shared/widgets/sidebar_widget.dart';

class GiftsController extends GetxController {
  final isLoading  = true.obs;
  final gifts      = <dynamic>[].obs;
  final nameCtrl   = TextEditingController();
  final priceCtrl  = TextEditingController();
  final imageCtrl  = TextEditingController();
  final categoryCtrl = TextEditingController();

  @override
  void onInit() { super.onInit(); loadGifts(); }

  Future<void> loadGifts() async {
    isLoading.value = true;
    try {
      gifts.value = await AdminApi.to.getGifts();
    } catch (_) { gifts.value = []; }
    isLoading.value = false;
  }

  Future<void> addGift() async {
    if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) return;
    final ok = await AdminApi.to.addGift({
      'giftId':   DateTime.now().millisecondsSinceEpoch.toString(),
      'name':     nameCtrl.text,
      'price':    int.tryParse(priceCtrl.text) ?? 10,
      'image':    imageCtrl.text,
      'category': categoryCtrl.text.isEmpty ? 'Basic' : categoryCtrl.text,
      'animationType': 'default',
      'isActive': true,
    });
    if (ok) {
      nameCtrl.clear(); priceCtrl.clear(); imageCtrl.clear(); categoryCtrl.clear();
      loadGifts();
      Get.back();
      Get.snackbar('✅ Gift Added', 'New gift has been added',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteGift(String id) async {
    final ok = await AdminApi.to.deleteGift(id);
    if (ok) {
      Get.snackbar('🗑️ Deleted', 'Gift deactivated',
          snackPosition: SnackPosition.BOTTOM);
      loadGifts();
    }
  }
}

class GiftsView extends StatelessWidget {
  const GiftsView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(GiftsController());
    return Scaffold(
      backgroundColor: const Color(0xFF0F0E17),
      body: Row(
        children: [
          const SidebarWidget(selected: 2),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Text('Gift Management',
                        style: TextStyle(fontSize: 26,
                            fontWeight: FontWeight.w700, color: Colors.white)),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(context, ctrl),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Gift'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8906),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Obx(() {
                      if (ctrl.isLoading.value) {
                        return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFFF8906)));
                      }
                      return _GiftsGrid(ctrl: ctrl);
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, GiftsController ctrl) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF15141F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add New Gift',
                    style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 20),
                _field('Gift Name',  ctrl.nameCtrl),
                const SizedBox(height: 12),
                _field('Price (Coins)', ctrl.priceCtrl,
                    type: TextInputType.number),
                const SizedBox(height: 12),
                _field('Image URL', ctrl.imageCtrl),
                const SizedBox(height: 12),
                _field('Category (e.g. Basic, Luxury)', ctrl.categoryCtrl),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: Get.back,
                        child: const Text('Cancel',
                            style: TextStyle(color: Colors.white54))),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: ctrl.addGift,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8906),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Add Gift'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFB0B0C3)),
        filled: true,
        fillColor: const Color(0xFF1E1D2E),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2A2940))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFFF8906))),
      ),
    );
  }
}

class _GiftsGrid extends StatelessWidget {
  final GiftsController ctrl;
  const _GiftsGrid({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    if (ctrl.gifts.isEmpty) {
      return const Center(
          child: Text('No gifts yet. Add some!',
              style: TextStyle(color: Colors.white54)));
    }
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: ctrl.gifts.length,
      itemBuilder: (_, i) {
        final g = ctrl.gifts[i] as Map<String, dynamic>;
        final id = g['_id']?.toString() ?? '';
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15141F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF2A2940)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              g['image']?.toString().isNotEmpty == true
                  ? Image.network(g['image'].toString(),
                      height: 60, width: 60,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.card_giftcard,
                              color: Color(0xFFFF8906), size: 50))
                  : const Icon(Icons.card_giftcard,
                      color: Color(0xFFFF8906), size: 50),
              const SizedBox(height: 8),
              Text(g['name']?.toString() ?? 'Gift',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text('${g['price'] ?? 0} Coins',
                  style: const TextStyle(
                      color: Color(0xFFFF8906), fontSize: 12)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ctrl.deleteGift(id),
                style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFCF6679),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4)),
                child: const Text('Remove', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        );
      },
    );
  }
}
