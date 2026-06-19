// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/ranking/presentation/bindings/ranking_binding.dart
// ARVIND PARTY - RANKING BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/ranking_controller.dart';

class RankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RankingController>(() => RankingController());
  }
}