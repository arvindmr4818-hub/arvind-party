// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/repositories/home_repository.dart
// ARVIND PARTY - HOME REPOSITORY (Banners, Categories, Rooms by type)
// ═══════════════════════════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import '../../../../core/constants/env_config.dart';
import '../../models/home_model.dart';

class HomeRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await _dio.get('/home/banners');
      return (response.data['data'] as List)
          .map((e) => BannerModel.fromJson(e))
          .toList();
    } catch (e) {
      // Return mock data if API fails (for production, handle properly)
      return _mockBanners();
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dio.get('/home/categories');
      return (response.data['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } catch (e) {
      return _mockCategories();
    }
  }

  Future<List<HomeRoomItem>> getRoomsByType(String type) async {
    try {
      final response = await _dio.get('/rooms/list', queryParameters: {'type': type});
      return (response.data['data'] as List)
          .map((e) => HomeRoomItem.fromJson(e))
          .toList();
    } catch (e) {
      return _mockRooms(type);
    }
  }

  // --- MOCK DATA FOR PRODUCTION TESTING ---
  List<BannerModel> _mockBanners() => [
    BannerModel(id: '1', imageUrl: 'https://picsum.photos/800/400?random=1', title: 'Welcome to Roomify!'),
    BannerModel(id: '2', imageUrl: 'https://picsum.photos/800/400?random=2', title: 'VIP Exclusive Access'),
    BannerModel(id: '3', imageUrl: 'https://picsum.photos/800/400?random=3', title: 'Live Events Tonight'),
  ];

  List<CategoryModel> _mockCategories() => [
    CategoryModel(id: '1', name: 'Music', iconUrl: '🎵', colorHex: '#FF6B6B'),
    CategoryModel(id: '2', name: 'Gaming', iconUrl: '🎮', colorHex: '#4ECDC4'),
    CategoryModel(id: '3', name: 'Talk', iconUrl: '💬', colorHex: '#45B7D1'),
    CategoryModel(id: '4', name: 'Education', iconUrl: '📚', colorHex: '#F7DC6F'),
    CategoryModel(id: '5', name: 'Sports', iconUrl: '⚽', colorHex: '#2ECC71'),
    CategoryModel(id: '6', name: 'Art', iconUrl: '🎨', colorHex: '#9B59B6'),
  ];

  List<HomeRoomItem> _mockRooms(String type) {
    final baseList = List.generate(5, (index) => HomeRoomItem(
      id: '${type}_$index',
      name: '$type Room ${index + 1}',
      imageUrl: 'https://picsum.photos/200/200?random=${index + 10}',
      memberCount: (100 + index * 50),
      type: type,
      hostName: 'Host ${index + 1}',
    ));
    return baseList;
  }
}