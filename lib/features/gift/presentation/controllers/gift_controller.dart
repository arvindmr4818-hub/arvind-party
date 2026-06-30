import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/socket/socket_service.dart';

class GiftController extends GetxController {
  final ApiService _api = Get.find<ApiService>();

  final gifts = <Map<String, dynamic>>[].obs;
  final categories = <String>[].obs;
  final selectedCategory = 'All'.obs;
  final selectedGift = Rx<Map<String, dynamic>?>(null);
  final isLoading = false.obs;
  final isSending = false.obs;
  final userCoins = 0.obs;

  List<Map<String, dynamic>> get filteredGifts {
    if (selectedCategory.value == 'All') return gifts;
    return gifts.where((g) => g['category'] == selectedCategory.value).toList();
  }

  @override
  void onInit() { super.onInit(); loadGifts(); _loadBalance(); }

  Future<void> loadGifts() async {
    isLoading.value = true;
    try {
      final res = await _api.get('/gifts');
      if (res['success'] == true) {
        gifts.value = List<Map<String, dynamic>>.from(res['data'] ?? []);
        final cats = gifts.map((g) => g['category'] as String? ?? 'basic').toSet().toList();
        categories.value = ['All', ...cats];
      }
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _loadBalance() async {
    try {
      final res = await _api.get('/wallet/balance');
      if (res['success'] == true) userCoins.value = res['data']?['coins'] ?? 0;
    } catch (_) {}
  }

  Future<void> sendGift({required String roomId, String? targetUserId}) async {
    final gift = selectedGift.value;
    if (gift == null) return;
    final price = gift['price'] as int? ?? 0;
    if (userCoins.value < price) {
      Get.snackbar('Insufficient Coins', 'You need $price coins to send this gift',
        backgroundColor: const Color(0xFFFF4757), colorText: const Color(0xFFFFFFFF));
      return;
    }
    isSending.value = true;
    try {
      final res = await _api.post('/gifts/send', {
        'giftId': gift['_id'],
        'roomId': roomId,
        if (targetUserId != null) 'receiverId': targetUserId,
      });
      if (res['success'] == true) {
        userCoins.value -= price;
        Get.back(); // Close sheet
        Get.snackbar('Gift Sent! 🎁', 'You sent ${gift['name']}',
          backgroundColor: const Color(0xFFFF8906), colorText: const Color(0xFF000000));
        selectedGift.value = null;
      } else {
        Get.snackbar('Failed', res['message'] ?? 'Could not send gift',
          backgroundColor: const Color(0xFFFF4757), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    isSending.value = false;
  }
}
