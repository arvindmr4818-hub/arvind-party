import 'package:get/get.dart';
import '../models/gift_model.dart';
import '../repositories/gift_repository.dart';

class GiftController extends GetxController {
  final GiftRepository _repo = GiftRepository();

  final gifts = <GiftModel>[].obs;
  final filteredGifts = <GiftModel>[].obs;
  final giftHistory = <GiftHistoryModel>[].obs;
  final giftRanking = <Map<String, dynamic>>[].obs;
  final balance = 0.0.obs;
  final isLoading = false.obs;
  final selectedCategory = Rxn<GiftCategory>();

  @override
  void onInit() {
    super.onInit();
    loadGifts();
    loadBalance();
  }

  Future<void> loadGifts() async {
    isLoading.value = true;
    try {
      gifts.assignAll(await _repo.getGifts());
      _applyFilter();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadBalance() async => balance.value = await _repo.getBalance();

  void filterByCategory(GiftCategory? category) {
    selectedCategory.value = category;
    _applyFilter();
  }

  void _applyFilter() {
    filteredGifts.assignAll(
      selectedCategory.value == null ? gifts : gifts.where((g) => g.category == selectedCategory.value).toList(),
    );
  }

  Future<void> sendGift(String receiverId, GiftModel gift, {int quantity = 1, String? roomId}) async {
    final totalCost = gift.price * quantity;
    if (balance.value < totalCost) {
      Get.snackbar('Error', 'Insufficient balance!');
      return;
    }
    try {
      await _repo.sendGift(receiverId, gift.id, quantity: quantity, roomId: roomId);
      balance.value -= totalCost;
      giftHistory.insert(0, GiftHistoryModel(
        id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
        senderId: '',
        senderName: 'Me',
        receiverId: receiverId,
        receiverName: 'User',
        gift: gift,
        quantity: quantity,
        createdAt: DateTime.now(),
      ));
      Get.snackbar('Success', 'Gift sent!');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send gift');
    }
  }

  Future<void> loadHistory() async => giftHistory.assignAll(await _repo.getGiftHistory());

  Future<void> loadRanking() async {
    try {
      isLoading.value = true;
      giftRanking.assignAll([
        {'userId': 'u1', 'username': 'Alice', 'totalGifts': 150, 'totalCoins': 15000},
        {'userId': 'u2', 'username': 'Bob', 'totalGifts': 120, 'totalCoins': 12000},
        {'userId': 'u3', 'username': 'Charlie', 'totalGifts': 90, 'totalCoins': 9000},
      ]);
    } finally {
      isLoading.value = false;
    }
  }
}