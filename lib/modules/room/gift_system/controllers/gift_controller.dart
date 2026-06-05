import 'package:get/get.dart';
import '../models/gift_model.dart';
import '../models/gift_category_model.dart';
import '../models/gift_transaction_model.dart';

class GiftController extends GetxController {
  // 1. Reactive Interface Core Arrays Streams
  final giftCategories = <GiftCategoryModel>[].obs;
  final activeGiftsList = <GiftModel>[].obs;
  final transactionHistory = <GiftTransactionModel>[].obs;

  // 2. Active Selection Monitoring Markers
  final selectedCategoryId = ''.obs;
  final selectedGiftId = ''.obs;
  final targetReceiverId = ''.obs; // Current selected mic seat user ID
  final targetReceiverName = 'Room Host'.obs;

  // 3. Billing Engine Registers & Multiplier Combo Signals
  final userWalletBalance = 25000.obs; // Dummy Coin Balance
  final comboCount = 0.obs;
  final isProcessingTransaction = false.obs;

  // 4. Live Render Stream Pipeline Nodes for UI Overlays Triggers
  final activeOverlayGift = Rxn<GiftModel>();
  final activeComboMultiplier = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _bootMonetizationDataCatalog();
  }

  // Pre-seed local dummy storage representing server cache lookups
  void _bootMonetizationDataCatalog() {
    giftCategories.assignAll([
      const GiftCategoryModel(id: "cat_popular", name: "Popular 🔥"),
      const GiftCategoryModel(
          id: "cat_vip", name: "VIP 👑", isPremiumOnly: true),
      const GiftCategoryModel(id: "cat_luxury", name: "Luxury 💎"),
      const GiftCategoryModel(id: "cat_lucky", name: "Lucky 🍀"),
    ]);

    if (giftCategories.isNotEmpty) {
      selectedCategoryId.value = giftCategories.first.id;
      loadCategoryGifts(giftCategories.first.id);
    }
  }

  // Category Filtering Logic mapping arrays criteria
  void loadCategoryGifts(String categoryId) {
    selectedCategoryId.value = categoryId;
    selectedGiftId.value = ''; // Flush selection markers upon shifting grids

    // Static mapping catalog configurations items drops
    if (categoryId == "cat_popular") {
      activeGiftsList.assignAll([
        const GiftModel(id: "g_rose", name: "Rose", icon: "🌹", price: 10),
        const GiftModel(id: "g_heart", name: "Heart", icon: "❤️", price: 50),
        const GiftModel(id: "g_cake", name: "Cake", icon: "🎂", price: 100),
      ]);
    } else if (categoryId == "cat_vip") {
      activeGiftsList.assignAll([
        const GiftModel(
            id: "g_crown",
            name: "Royal Crown",
            icon: "👑",
            price: 500,
            isAnimated: true,
            animationType: GiftAnimationType.lottie),
        const GiftModel(
            id: "g_car",
            name: "Super Car",
            icon: "🚗",
            price: 1200,
            isAnimated: true,
            animationType: GiftAnimationType.svga),
      ]);
    } else if (categoryId == "cat_luxury") {
      activeGiftsList.assignAll([
        const GiftModel(
            id: "g_yacht",
            name: "Mega Yacht",
            icon: "🛥️",
            price: 5000,
            isAnimated: true,
            isFullScreen: true,
            animationType: GiftAnimationType.svga),
        const GiftModel(
            id: "g_rocket",
            name: "Star Rocket",
            icon: "🚀",
            price: 10000,
            isAnimated: true,
            isFullScreen: true,
            animationType: GiftAnimationType.lottie),
      ]);
    } else if (categoryId == "cat_lucky") {
      activeGiftsList.assignAll([
        const GiftModel(
            id: "g_lucky_clover",
            name: "Gold Clover",
            icon: "🍀",
            price: 20,
            isLuckyGift: true),
        const GiftModel(
            id: "g_lucky_box",
            name: "Mystery Vault",
            icon: "🎁",
            price: 200,
            isLuckyGift: true),
      ]);
    }
  }

  void selectGiftItem(String id) {
    selectedGiftId.value = id;
    comboCount.value = 0; // Clear multiplier tracks upon swapping targets
  }

  // Combo Increment Counter Module Block
  void triggerComboIncrement() {
    if (selectedGiftId.value.isEmpty) {
      Get.snackbar(
          "Monetization", "Please pick an item from store grids first.");
      return;
    }
    comboCount.value++;
    _executeDeductionAndBroadcast(isComboStreak: true);
  }

  // Main Execution Core Logic Pipeline Function
  Future<void> executeSingleGiftDispatch() async {
    if (selectedGiftId.value.isEmpty) {
      Get.snackbar("Monetization", "Please select a gift item to send.");
      return;
    }
    comboCount.value = 1;
    await _executeDeductionAndBroadcast(isComboStreak: false);
  }

  // Atomic Verification Ledger Deductions Wrapper Method
  Future<void> _executeDeductionAndBroadcast(
      {required bool isComboStreak}) async {
    final GiftModel targetItem =
        activeGiftsList.firstWhere((g) => g.id == selectedGiftId.value);
    final int transactionCost = targetItem.price;

    if (userWalletBalance.value < transactionCost) {
      Get.snackbar(
          "Insufficient Funds", "Please recharge your coins vault balance.");
      comboCount.value = 0;
      return;
    }

    try {
      isProcessingTransaction.value = true;

      // Debit Wallet immediately (Optimistic local rendering strategy model)
      userWalletBalance.value -= transactionCost;

      // Sockets Realtime Multi-nodes parameters data pipeline hook placeholder:
      // socket.emit('send_room_gift', { giftId: targetItem.id, combo: comboCount.value, receiver: targetReceiverId.value });

      // Trigger local presentation animation engine node models
      activeOverlayGift.value = targetItem;
      activeComboMultiplier.value = comboCount.value;

      // Compile internal logs structure tracking registers
      final freshLog = GiftTransactionModel(
        id: "tx_${DateTime.now().millisecondsSinceEpoch}",
        senderId: "me_123",
        senderName: "Arvind (You)",
        receiverId: targetReceiverId.value.isNotEmpty
            ? targetReceiverId.value
            : "host_root",
        receiverName: targetReceiverName.value,
        giftId: targetItem.id,
        giftName: targetItem.name,
        totalCoins: transactionCost,
        comboMultiplier: comboCount.value,
        timestamp: DateTime.now(),
      );

      transactionHistory.insert(0, freshLog);
    } catch (e) {
      // Refund balance upon backend critical communication fault line rollbacks
      userWalletBalance.value += transactionCost;
      Get.snackbar("Transaction Fault", "Failed to clear ledgers pipeline: $e");
    } finally {
      isProcessingTransaction.value = false;
    }
  }
}
