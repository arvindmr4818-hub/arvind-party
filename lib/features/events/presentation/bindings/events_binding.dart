// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/events/presentation/bindings/events_binding.dart
// ARVIND PARTY - EVENTS BINDING
// ═══════════════════════════════════════════════════════════════════════════

import 'package:get/get.dart';
import '../controllers/events_controller.dart';

class EventsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EventsController>(() => EventsController());
  }
}