import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/agency_event_controller.dart';

class AgencyEventsScreen extends StatelessWidget {
  const AgencyEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AgencyEventController eventController =
        Get.put(AgencyEventController());

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
          "Talent Recruitment Tournaments",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(12.0),
            child: Obx(() {
              if (eventController.institutionalEventsList.isEmpty) {
                return const Center(
                  child: Text("No corporate talent search campaigns running.",
                      style: TextStyle(color: Colors.white24)),
                );
              }

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: eventController.institutionalEventsList.length,
                itemBuilder: (context, index) {
                  final eventItem =
                      eventController.institutionalEventsList[index];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xff15141F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(eventItem.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                            const Icon(Icons.workspace_premium_outlined,
                                color: Colors.amber, size: 18),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(eventItem.description,
                            style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                height: 1.3)),
                        const Divider(color: Colors.white10, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Prize Pool Allocation",
                                    style: TextStyle(
                                        color: Colors.white24, fontSize: 9)),
                                Text(eventItem.prizePoolDetails,
                                    style: const TextStyle(
                                        color: Colors.amber,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                  color: Colors.cyan.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                  "Hosts: ${eventItem.participatingHostsCount}",
                                  style: const TextStyle(
                                      color: Colors.cyan,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}
