// lib/core/network/pk_battle_binding.dart
import 'package:get/get.dart';
import '../../modules/wallet/controllers/pk_battle_controller.dart';

class PkBattleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PkBattleController>(() => PkBattleController());
  }
}
