import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/event_model.dart';

class EventsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final GetStorage _storage = GetStorage();

  // ── Reactive State Variables ───────────────────────────────────
  final isLoading = false.obs;
  final events = <AppEventModel>[].obs;
  final joinedEventIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadJoinedEventsFromStorage();
    loadEventsFromBackend(); // Real backend call on initialization
  }

  // 📦 Local Storage se pehle se join kiye hue events load karna
  void _loadJoinedEventsFromStorage() {
    final list = _storage.read<List<dynamic>>('joined_events') ?? [];
    joinedEventIds.assignAll(list.map((e) => e.toString()).toList());
  }

  // 🌐 REAL TIME API: Backend se active events fetch karna
  Future<void> loadEventsFromBackend() async {
    try {
      isLoading.value = true;
      
      // Aapka real Node.js route: router.get('/events', ...)
      final response = await _api.get('/events');
      
      if (response != null && response['success'] == true) {
        final List<dynamic> eventData = response['data'] ?? [];
        
        // Response data ko model class me map karke reactive list me daalna
        final parsedList = eventData
            .map((e) => AppEventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
            
        events.assignAll(parsedList);
      } else {
        _showErrorSnackbar('Fetch Failed', 'Server returned an invalid response environment.');
      }
    } catch (e) {
      debugPrint('Error loading events from database: $e');
      _showErrorSnackbar('Server Error', 'Could not connect to the event endpoint.');
    } finally {
      isLoading.value = false;
    }
  }

  // ⚔️ REAL TIME API: Kisi event ko live join karna (Database mapping sync)
  Future<bool> joinEvent(String eventId) async {
    try {
      // Aapka real Node.js route: router.post('/events/:id/join', ...)
      final response = await _api.post('/events/$eventId/join', );
      
      if (response != null && response['success'] == true) {
        if (!joinedEventIds.contains(eventId)) {
          joinedEventIds.add(eventId);
          // Local storage update taaki app band karke kholne par bhi saved rahe
          _storage.write('joined_events', joinedEventIds.toList());
        }
        
        Get.snackbar(
          'Success 🎉', 
          'You have successfully registered for this tournament event!',
          backgroundColor: const Color(0xFF15141F),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM
        );
        return true;
      } else {
        _showErrorSnackbar('Action Denied', 'Backend constraints prevented joining this event frame.');
        return false;
      }
    } catch (e) {
      debugPrint('Error joining event framework: $e');
      _showErrorSnackbar('Connection Error', 'Failed to transmit join protocol to the server.');
      return false;
    }
  }

  // Check if specific event is already registered
  bool isJoined(String eventId) => joinedEventIds.contains(eventId);

  // ⏳ Real-Time Remaining Time Calculator
  String getEventTimeRemaining(AppEventModel event) {
    final now = DateTime.now();
    if (event.endDate.isBefore(now)) return 'Ended';
    
    final diff = event.endDate.difference(now);
    if (diff.inDays > 0) return 'Ends in ${diff.inDays} Days';
    if (diff.inHours > 0) return 'Ends in ${diff.inHours} Hours';
    return 'Ending Soon';
  }

  // Global standard snackbar wrapper for error streams
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title, 
      message,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16)
    );
  }
}