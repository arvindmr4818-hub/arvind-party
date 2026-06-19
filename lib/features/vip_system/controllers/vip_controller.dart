// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/vip_system/controllers/vip_controller.dart
// ARVIND PARTY - VIP CONTROLLER
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/vip_model.dart';
import '../repositories/vip_repository.dart';

class VIPController extends GetxController {
  final vipRepository = VIPRepository();
  final storage = GetStorage();

  // Observable variables
  var vipTiers = <VIPTier>[].obs;
  var userVIPStatus = Rxn<UserVIPStatus>();
  var isLoading = false.obs;
  var selectedVIPTier = Rxn<VIPTier>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVIPTiers();
    checkUserVIPStatus();
  }

  void fetchVIPTiers() async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      final tiers = await vipRepository.getVIPTiers();
      vipTiers.value = tiers;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void checkUserVIPStatus() async {
    try {
      final token = storage.read('token') ?? '';
      if (token.isEmpty) return;

      final status = await vipRepository.getUserVIPStatus(token);
      userVIPStatus.value = status;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  void selectVIPTier(VIPTier tier) {
    selectedVIPTier.value = tier;
  }

  void purchaseVIP(VIPTier tier) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = storage.read('token') ?? '';
      if (token.isEmpty) {
        throw Exception('Not logged in');
      }

      await vipRepository.purchaseVIP(token, tier.id);
      
      Get.snackbar(
        'Success',
        'VIP purchase initiated',
        duration: const Duration(seconds: 2),
      );

      // Activate VIP after purchase
      activateVIP(tier.id);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void activateVIP(String vipTierId) async {
    try {
      final token = storage.read('token') ?? '';
      if (token.isEmpty) throw Exception('Not logged in');

      await vipRepository.activateVIP(token, vipTierId);
      
      // Refresh status
      checkUserVIPStatus();
      
      Get.snackbar('Success', 'VIP activated successfully!');
    } catch (e) {
      Get.snackbar('Error', 'Activation failed: $e');
    }
  }

  bool hasVIPAccess(String requiredTier) {
    if (requiredTier == 'free') return true;
    if (userVIPStatus.value == null) return false;

    const tierHierarchy = {
      'free': 0,
      'vip1': 1,
      'vip5': 5,
      'vip10': 10,
      'vip15': 15,
      'svip10': 20,
      'svip15': 25,
    };

    final userLevel = tierHierarchy[userVIPStatus.value?.vipTier] ?? 0;
    final requiredLevel = tierHierarchy[requiredTier] ?? 0;

    return userLevel >= requiredLevel && userVIPStatus.value!.isActive;
  }

  int getDaysRemaining() {
    if (userVIPStatus.value == null) return 0;
    final diff = userVIPStatus.value!.expiryDate.difference(DateTime.now());
    return diff.inDays > 0 ? diff.inDays : 0;
  }

  bool isVIPExpired() {
    if (userVIPStatus.value == null) return false;
    return DateTime.now().isAfter(userVIPStatus.value!.expiryDate);
  }
}