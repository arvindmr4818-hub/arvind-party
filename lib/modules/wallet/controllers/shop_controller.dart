import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';

// ── REAL SHOP ITEM MODEL ─────────────────────────────────────────
class ShopItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int priceCoins;
  final int priceDiamonds;
  final String type; // frame, badge, gift, theme, sticker, vip
  final String rarity; // common, rare, epic, legendary
  final int durationDays; // ✅ FIX 1: Added duration field mapping required by screen layout
  final bool isOwned;
  final bool isVipOnly;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.priceCoins,
    required this.priceDiamonds,
    required this.type,
    required this.rarity,
    required this.durationDays,
    required this.isOwned,
    required this.isVipOnly,
  });

  ShopItem copyWith({bool? isOwned}) {
    return ShopItem(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      priceCoins: priceCoins,
      priceDiamonds: priceDiamonds,
      type: type,
      rarity: rarity,
      durationDays: durationDays,
      isOwned: isOwned ?? this.isOwned,
      isVipOnly: isVipOnly,
    );
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      priceCoins: (json['priceCoins'] as num?)?.toInt() ?? 0,
      priceDiamonds: (json['priceDiamonds'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'frame',
      rarity: json['rarity']?.toString() ?? 'common',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 7, // Default fallback validation mapping
      isOwned: json['isOwned'] == true,
      isVipOnly: json['isVipOnly'] == true,
    );
  }
}

// ── SHOP GETX CONTROLLER ENVIRONMENT ─────────────────────────────
class ShopController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ── Reactive State Variables ───────────────────────────────────
  final isLoading = false.obs;
  final selectedCategory = 'all'.obs;
  final items = <ShopItem>[].obs;
  final ownedIds = <String>{}.obs;

  static const categories = ['all', 'frame', 'badge', 'gift', 'theme', 'sticker', 'vip'];

  @override
  void onInit() {
    super.onInit();
    _loadOwnedFromCache();
    loadItems();
  }

  void _loadOwnedFromCache() {
    final list = _storage.read<List>('owned_shop_items') ?? [];
    ownedIds.assignAll(list.map((e) => e.toString()));
  }

  // 🌐 REAL TIME API: Fetch virtual assets shop catalog from database
  Future<void> loadItems({String? category}) async {
    try {
      isLoading.value = true;
      selectedCategory.value = category ?? selectedCategory.value;
      
      // Node.js Endpoint: /shop/items?category=all
      final response = await _api.get('/shop/items', query: {'category': selectedCategory.value});
      
      if (response is Map && response['success'] == true) {
        final List<dynamic> serverData = response['data'] ?? [];
        final list = serverData
            .map((e) => ShopItem.fromJson(Map<String, dynamic>.from(e)))
            .map((item) => item.copyWith(isOwned: ownedIds.contains(item.id)))
            .toList();
            
        items.assignAll(list);
      } else {
        items.clear(); // Real empty frame validation
      }
    } catch (e) {
      debugPrint('Database asset engine lookup failure: $e');
      items.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ⚔️ REAL TIME API: Purchase transactional ledger sync on backend
  Future<bool> purchase(ShopItem item) async {
    try {
      isLoading.value = true;
      
      // Node.js Purchase Router Endpoint post parameters handshake
      final response = await _api.post('/shop/purchase', body: {'itemId': item.id});
      
      if (response is Map && response['success'] == true) {
        ownedIds.add(item.id);
        _storage.write('owned_shop_items', ownedIds.toList());
        
        // Re-mapping local runtime items array data instantly
        final updatedList = items.map((i) {
          if (i.id == item.id) return i.copyWith(isOwned: true);
          return i;
        }).toList();
        items.assignAll(updatedList);
        
        Get.snackbar('Purchase Successful 🎉', 'Asset registered to user environment profile inventory.');
        return true;
      }
    } catch (e) {
      debugPrint('Shop checkout engine transaction crash: $e');
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // ✅ Method wrappers requested by screen bindings interface models
  void selectCategory(String c) {
    selectedCategory.value = c;
    loadItems(category: c);
  }

  List<ShopItem> get filteredItems {
    if (selectedCategory.value == 'all') return items.toList();
    return items.where((i) => i.type == selectedCategory.value).toList();
  }
}