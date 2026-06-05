import 'package:get/get.dart';
import '../models/event_model.dart';

class EventsController extends GetxController {
  final isLoading = false.obs;
  final events = <AppEventModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadEvents();
  }

  void _loadEvents() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600)); // Fake API delay
    events.assignAll([
      AppEventModel(
          id: 'e1',
          title: 'Summer PK Championship',
          description: 'Compete in PK battles to win up to 100,000 Diamonds!',
          bannerUrl: 'https://picsum.photos/seed/event1/800/400',
          endDate: 'Ends in 5 Days'),
      AppEventModel(
          id: 'e2',
          title: 'New User Welcome Bonus',
          description:
              'Recharge for the first time and get 50% extra bonus diamonds.',
          bannerUrl: 'https://picsum.photos/seed/event2/800/400',
          endDate: 'Ongoing'),
    ]);
    isLoading.value = false;
  }
}
