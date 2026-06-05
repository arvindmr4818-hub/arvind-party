import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_analytics_controller.dart';

class AgencyAnalyticsScreen extends StatelessWidget {
  const AgencyAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AgencyAnalyticsController chartController =
        Get.put(AgencyAnalyticsController());

    return Scaffold(
      backgroundColor: const Color(0xff0F0E17),
      appBar: AppBar(
        backgroundColor: const Color(0xff15141F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Performance Analytics Dashboard",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 550),
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Macro Business Scalability Metrics",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),

                  // Scalar Performance Grid Indicators Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricMiniBox(
                          "Gross Volume",
                          "\$${chartController.cumulativeRevenueUSD.value}",
                          Icons.stacked_line_chart,
                          Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildMetricMiniBox(
                          "Streaming Capacity",
                          "${chartController.standardBroadcastingHours.value} Hrs",
                          Icons.hourglass_empty_rounded,
                          Colors.cyan,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Data Series Logging Matrix Block
                  const Text("Daily Operational Sequence Logs",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: const Color(0xff15141F),
                        borderRadius: BorderRadius.circular(12)),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: chartController.seriesTimelineMetrics.length,
                      itemBuilder: (context, idx) {
                        final dataPair =
                            chartController.seriesTimelineMetrics[idx];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dataPair['date'],
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                              Text("Revenue: \$${dataPair['revenue']}",
                                  style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Text("${dataPair['hours']} total hrs",
                                  style: const TextStyle(
                                      color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricMiniBox(
      String title, String data, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: const Color(0xff15141F),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
          const SizedBox(height: 2),
          Text(data,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
