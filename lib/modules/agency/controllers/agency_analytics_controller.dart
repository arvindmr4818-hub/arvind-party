import 'package:get/get.dart';

class AgencyAnalyticsController extends GetxController {
  // Analytical scalar matrix properties
  final cumulativeRevenueUSD = 14500.50.obs;
  final currentActiveHostsCount = 42.obs;
  final standardBroadcastingHours = 384.5.obs;

  // Daily charting tracking lists data pairs representation
  final seriesTimelineMetrics = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    compileAnalyticsDataBlocks();
  }

  void compileAnalyticsDataBlocks() {
    seriesTimelineMetrics.assignAll([
      {"date": "June 01", "revenue": 1200, "hours": 45},
      {"date": "June 02", "revenue": 1900, "hours": 52},
      {"date": "June 03", "revenue": 1450, "hours": 40},
    ]);
  }
}
