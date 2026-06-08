// lib/modules/wallet/bindings/wallet_binding.dart
import 'package:get/get.dart';
import '../views/wallet_screen.dart';
import '../controllers/mini_games_controller.dart';
import '../controllers/pk_battle_controller.dart';
import '../controllers/shop_controller.dart';
import '../controllers/user_center_controller.dart';
import '../controllers/search_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/youtube_controller.dart';
import '../controllers/withdrawal_controller.dart';
import '../controllers/withdrawal_admin_controller.dart';
import '../controllers/events_controller.dart';
import '../controllers/audio_player_controller.dart';
import '../../chat/controllers/chat_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    // The main wallet controller is registered on-demand (lazy)
    // via Get.put inside WalletScreen. Other controllers are also
    // lazy so they are only created when their respective screen
    // is opened.
    Get.lazyPut<MiniGamesController>(() => MiniGamesController(), fenix: true);
    Get.lazyPut<PkBattleController>(() => PkBattleController(), fenix: true);
    Get.lazyPut<ShopController>(() => ShopController(), fenix: true);
    Get.lazyPut<UserCenterController>(() => UserCenterController(), fenix: true);
    Get.lazyPut<GlobalSearchController>(() => GlobalSearchController(), fenix: true);
    Get.lazyPut<NotificationController>(() => NotificationController(), fenix: true);
    Get.lazyPut<YoutubeController>(() => YoutubeController(), fenix: true);
    Get.lazyPut<WithdrawalController>(() => WithdrawalController(), fenix: true);
    Get.lazyPut<WithdrawalAdminController>(() => WithdrawalAdminController(), fenix: true);
    Get.lazyPut<EventsController>(() => EventsController(), fenix: true);
    Get.lazyPut<AudioPlayerController>(() => AudioPlayerController(), fenix: true);
    Get.lazyPut<ChatController>(() => ChatController(), fenix: true);
  }
}
