import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/room_settings_controller.dart';

class RoomSeatCard extends StatelessWidget {
  const RoomSeatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final RoomSettingsController controller =
        Get.find<RoomSettingsController>();
    final List<int> seatChoices = [8, 10, 15, 20, 25];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff15141F),
        borderRadius: BorderRadius.circular(14),
        // ✅ Fix 1
        border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_view_rounded,
                  color: Colors.purpleAccent, size: 20),
              SizedBox(width: 8),
              Text("Mic Seat Multi-Grid Rules",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Dynamically scale room layouts. Changing seats will shift real-time streams instantly.",
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 14),

          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: seatChoices.length,
              itemBuilder: (context, index) {
                final count = seatChoices[index];
                return Obx(() {
                  bool isSelected = controller.seatCount.value == count;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text("$count Mics Grid"),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xffFF8906),
                      backgroundColor: const Color(0xff0F0E17),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      side: BorderSide(
                          color: isSelected
                              ? const Color(0xffFF8906)
                              // ✅ Fix 2
                              : Colors.white.withValues(alpha: 0.05)),
                      // ✅ Fix 3: changeSeatCount → updateSeatCount
                      onSelected: (selected) {
                        if (selected) controller.updateSeatCount(count);
                      },
                    ),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}