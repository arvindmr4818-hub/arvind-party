import 'package:dio/dio.dart';
import '../../../core/constants/env_config.dart';
import '../models/gift_model.dart';

class GiftRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: EnvConfig.plainApiBaseUrl));

  Future<List<GiftModel>> getGifts({String? category}) async {
    try {
      final response = await _dio.get('/gifts', queryParameters: {'category': category});
      return (response.data['data'] as List).map((e) => GiftModel.fromJson(e)).toList();
    } catch (e) { return _mockGifts(); }
  }

  Future<void> sendGift(String receiverId, String giftId, {int quantity = 1, String? roomId}) async =>
    await _dio.post('/gifts/send', data: {'receiverId': receiverId, 'giftId': giftId, 'quantity': quantity, 'roomId': roomId});

  Future<List<GiftHistoryModel>> getGiftHistory() async {
    try {
      final response = await _dio.get('/gifts/history');
      return (response.data['data'] as List).map((e) => GiftHistoryModel.fromJson(e)).toList();
    } catch (e) { return _mockHistory(); }
  }

  Future<double> getBalance() async {
    try {
      final response = await _dio.get('/user/balance');
      return (response.data['balance'] ?? 0.0).toDouble();
    } catch (e) { return 5000.0; }
  }

  List<GiftModel> _mockGifts() => [
    GiftModel(id: 'g1', name: 'Rose', type: GiftType.static, category: GiftCategory.normal, price: 50, previewImageUrl: 'https://picsum.photos/seed/rose/200'),
    GiftModel(id: 'g2', name: 'Heart Beat', type: GiftType.animated, category: GiftCategory.normal, price: 100, previewImageUrl: 'https://picsum.photos/seed/heart/200', animationUrl: 'https://example.com/heart.gif'),
    GiftModel(id: 'g3', name: 'Dragon Dance', type: GiftType.svga, category: GiftCategory.festival, price: 500, previewImageUrl: 'https://picsum.photos/seed/dragon/200', animationUrl: 'https://example.com/dragon.svga'),
    GiftModel(id: 'g4', name: 'Fireworks', type: GiftType.mp4, category: GiftCategory.festival, price: 800, previewImageUrl: 'https://picsum.photos/seed/fire/200', animationUrl: 'https://example.com/fireworks.mp4'),
    GiftModel(id: 'g5', name: '99 Roses', type: GiftType.combo, category: GiftCategory.normal, price: 990, previewImageUrl: 'https://picsum.photos/seed/99roses/200', comboCount: 99, comboAnimationUrl: 'https://example.com/99roses.mp4'),
    GiftModel(id: 'g6', name: 'Lucky Box', type: GiftType.animated, category: GiftCategory.lucky, price: 200, previewImageUrl: 'https://picsum.photos/seed/lucky/200', isLucky: true, luckyMinCoins: 50, luckyMaxCoins: 500),
    GiftModel(id: 'g7', name: 'Golden Crown', type: GiftType.svga, category: GiftCategory.vip, price: 2000, previewImageUrl: 'https://picsum.photos/seed/crown/200', animationUrl: 'https://example.com/crown.svga', requiredVipLevel: 3),
    GiftModel(id: 'g8', name: 'Room Confetti', type: GiftType.mp4, category: GiftCategory.room, price: 150, previewImageUrl: 'https://picsum.photos/seed/confetti/200', animationUrl: 'https://example.com/confetti.mp4'),
  ];

  List<GiftHistoryModel> _mockHistory() {
    final gift = _mockGifts()[0];
    return List.generate(5, (i) => GiftHistoryModel(
      id: 'h$i', senderId: 'u1', senderName: 'Me', receiverId: 'u2', receiverName: 'Friend $i', gift: gift, quantity: i + 1,
      createdAt: DateTime.now().subtract(Duration(days: i)),
    ));
  }
}