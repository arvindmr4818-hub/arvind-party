// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/search/presentation/bindings/search_binding.dart
// ARVIND PARTY - SEARCH BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchController>(() => SearchController());
  }
}