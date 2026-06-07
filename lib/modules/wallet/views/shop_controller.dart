// lib/modules/wallet/views/shop_controller.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';

class ShopItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int priceCoins;
  final int priceDiamonds;
  final String type; // 'frame', 'badge', 'gift', 'theme', 'sticker', 'vip'
  final String rarity; // 'common', 'rare', 'epic', 'legendary'
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
      isOwned: isOwned ?? this.isOwned,
      isVipOnly: isVipOnly,
    );
  }

  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      priceCoins: (json['priceCoins'] as num?)?.toInt() ?? 0,
      priceDiamonds: (json['priceDiamonds'] as num?)?.toInt() ?? 0,
      type: (json['type'] ?? 'frame').toString(),
      rarity: (json['rarity'] ?? 'common').toString(),
      isOwned: json['isOwned'] == true,
      isVipOnly: json['isVipOnly'] == true,
    );
  }
}

class ShopController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

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

  Future<void> loadItems({String? category}) async {
    try {
      isLoading.value = true;
      selectedCategory.value = category ?? selectedCategory.value;
      final response = await _api.get('/shop/items', query: {'category': selectedCategory.value});
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => ShopItem.fromJson(Map<String, dynamic>.from(e)))
            .map((item) => item.copyWith(isOwned: ownedIds.contains(item.id)))
            .toList();
        if (list.isNotEmpty) {
          items.assignAll(list);
        } else {
          items.assignAll(_demoItems());
        }
      } else {
        items.assignAll(_demoItems());
      }
    } catch (_) {
      items.assignAll(_demoItems());
    } finally {
      isLoading.value = false;
    }
  }

  List<ShopItem> _demoItems() {
    return [
      ShopItem(id: 'f1', name: 'Golden Frame', description: 'A premium gold frame', imageUrl: '', priceCoins: 5000, priceDiamonds: 50, type: 'frame', rarity: 'epic', isOwned: false, isVipOnly: false),
      ShopItem(id: 'f2', name: 'Diamond Frame', description: 'A brilliant diamond frame', imageUrl: '', priceCoins: 20000, priceDiamonds: 200, type: 'frame', rarity: 'legendary', isOwned: false, isVipOnly: true),
      ShopItem(id: 'b1', name: 'Top Host Badge', description: 'Awarded to top hosts', imageUrl: '', priceCoins: 1000, priceDiamonds: 10, type: 'badge', rarity: 'rare', isOwned: false, isVipOnly: false),
      ShopItem(id: 'b2', name: 'Legend Badge', description: 'The legendary badge', imageUrl: '', priceCoins: 100000, priceDiamonds: 1000, type: 'badge', rarity: 'legendary', isOwned: false, isVipOnly: true),
      ShopItem(id: 'g1', name: 'Firework Gift', description: 'Send a firework to the room', imageUrl: '', priceCoins: 500, priceDiamonds: 5, type: 'gift', rarity: 'common', isOwned: false, isVipOnly: false),
      ShopItem(id: 'g2', name: 'Rocket Gift', description: 'Launch a rocket', imageUrl: '', priceCoins: 5000, priceDiamonds: 50, type: 'gift', rarity: 'epic', isOwned: false, isVipOnly: false),
      ShopItem(id: 't1', name: 'Dark Theme', description: 'A dark UI theme', imageUrl: '', priceCoins: 2000, priceDiamonds: 20, type: 'theme', rarity: 'common', isOwned: false, isVipOnly: false),
      ShopItem(id: 't2', name: 'Neon Theme', description: 'A vibrant neon theme', imageUrl: '', priceCoins: 8000, priceDiamonds: 80, type: 'theme', rarity: 'epic', isOwned: false, isVipOnly: false),
      ShopItem(id: 's1', name: 'Heart Sticker Pack', description: 'A pack of heart stickers', imageUrl: '', priceCoins: 100, priceDiamonds: 1, type: 'sticker', rarity: 'common', isOwned: false, isVipOnly: false),
      ShopItem(id: 'v1', name: 'VIP Pass 30 days', description: '30 days VIP status', imageUrl: '', priceCoins: 0, priceDiamonds: 999, type: 'vip', rarity: 'legendary', isOwned: false, isVipOnly: false),
    ];
  }

  Future<bool> purchase(ShopItem item) async {
    try {
      isLoading.value = true;
      final response = await _api.post('/shop/purchase', body: {'itemId': item.id});
      if (response is Map && response['success'] == true) {
        ownedIds.add(item.id);
        _storage.write('owned_shop_items', ownedIds.toList());
        items.refresh();
        return true;
      }
    } catch (_) {
      // local fallback
      ownedIds.add(item.id);
      _storage.write('owned_shop_items', ownedIds.toList());
      items.refresh();
      return true;
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  void selectCategory(String c) {
    selectedCategory.value = c;
    loadItems(category: c);
  }

  List<ShopItem> get filteredItems {
    if (selectedCategory.value == 'all') return items.toList();
    return items.where((i) => i.type == selectedCategory.value).toList();
  }
}
