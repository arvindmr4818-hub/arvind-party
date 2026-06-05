import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';

class ComboCounterWidget extends StatelessWidget {
  const ComboCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final GiftController controller = Get.find<GiftController>();

    return Obx(() {
      int count = controller.comboCount.value;
      bool hasActiveStreak = count > 0;

      return GestureDetector(
        onTap: () => controller.triggerComboIncrement(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: hasActiveStreak ? Matrix4.identity() : Matrix4.identity(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasActiveStreak
                  ? [const Color(0xffFF8906), Colors.deepOrange]
                  : [const Color(0xff1A1924), const Color(0xff1A1924)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: hasActiveStreak
                ? [
                    BoxShadow(
                        color: const Color(0xffFF8906).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasActiveStreak ? "MULTIPLIER" : "COMBO",
                style: TextStyle(
                  color: hasActiveStreak ? Colors.black : Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "x$count",
                  style: TextStyle(
                    color: hasActiveStreak ? Colors.white : Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
