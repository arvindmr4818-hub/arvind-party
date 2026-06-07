import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/api_service.dart';
import '../../../shared/models/event_model.dart';

class EventsController extends GetxController {
  final ApiService _api = Get.find<ApiService>();
  final isLoading = false.obs;
  final events = <AppEventModel>[].obs;
  final joinedEventIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadJoinedEvents();
    loadEvents();
  }

  void _loadJoinedEvents() {
    final box = GetStorage();
    final list = box.read<List<String>>('joined_events') ?? [];
    joinedEventIds.assignAll(list);
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      final response = await _api.get('/events');
      if (response is Map && response['success'] == true) {
        final list = (response['data'] as List? ?? [])
            .map((e) => AppEventModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        if (list.isEmpty) {
          // fallback to demo data
          events.assignAll(_demoEvents());
        } else {
          events.assignAll(list);
        }
      } else {
        events.assignAll(_demoEvents());
      }
    } catch (e) {
      events.assignAll(_demoEvents());
    } finally {
      isLoading.value = false;
    }
  }

  List<AppEventModel> _demoEvents() {
    return [
      AppEventModel(
          id: 'e1',
          title: 'Summer PK Championship',
          description: 'Compete in PK battles to win up to 100,000 Diamonds!',
          coverUrl: 'https://picsum.photos/seed/event1/800/400',
          startDate: DateTime.now().subtract(const Duration(days: 2)),
          endDate: DateTime.now().add(const Duration(days: 5)),
          rewardCoins: 100000,
          type: 'party',
          isActive: true),
      AppEventModel(
          id: 'e2',
          title: 'New User Welcome Bonus',
          description:
              'Recharge for the first time and get 50% extra bonus diamonds.',
          coverUrl: 'https://picsum.photos/seed/event2/800/400',
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now().add(const Duration(days: 60)),
          rewardCoins: 5000,
          type: 'global',
          isActive: true),
      AppEventModel(
          id: 'e3',
          title: 'Family Recruitment Drive',
          description: 'Invite friends to your family and earn rewards.',
          coverUrl: 'https://picsum.photos/seed/event3/800/400',
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 14)),
          rewardCoins: 10000,
          type: 'family',
          isActive: true),
    ];
  }

  Future<bool> joinEvent(String eventId) async {
    try {
      final response = await _api.post('/events/$eventId/join');
      if (response is Map && response['success'] == true) {
        joinedEventIds.add(eventId);
        GetStorage().write('joined_events', joinedEventIds.toList());
        return true;
      }
    } catch (_) {}
    // local fallback
    joinedEventIds.add(eventId);
    GetStorage().write('joined_events', joinedEventIds.toList());
    return true;
  }

  bool isJoined(String eventId) => joinedEventIds.contains(eventId);

  String getEventTimeRemaining(AppEventModel event) {
    final now = DateTime.now();
    if (event.endDate.isBefore(now)) return 'Ended';
    final diff = event.endDate.difference(now);
    if (diff.inDays > 0) return 'Ends in ${diff.inDays} Days';
    if (diff.inHours > 0) return 'Ends in ${diff.inHours} Hours';
    return 'Ending Soon';
  }
}
