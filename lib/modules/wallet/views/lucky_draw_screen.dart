import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'lucky_draw_controller.dart';

class LuckyDrawScreen extends StatelessWidget {
  const LuckyDrawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LuckyDrawController());

    return Scaffold(
      backgroundColor: const Color(0xFF2B0A3D), // Theme for lucky draw
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Lucky Wheel',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back()),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for actual wheel animation
            Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                        colors: [Colors.purpleAccent, Colors.deepPurple]),
                    boxShadow: [
                      if (controller.isSpinning.value)
                        const BoxShadow(
                            color: Colors.purpleAccent,
                            blurRadius: 40,
                            spreadRadius: 10)
                    ],
                    border: Border.all(color: Colors.amber, width: 4),
                  ),
                  child: Center(
                    child: controller.isSpinning.value
                        ? const CircularProgressIndicator(color: Colors.amber)
                        : const Text('❓', style: TextStyle(fontSize: 80)),
                  ),
                )),

            const SizedBox(height: 50),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => controller.spinWheel(1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Draw x1\n(20 💎)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => controller.spinWheel(10),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Draw x10\n(180 💎)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
