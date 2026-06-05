import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gift_controller.dart';

class GiftAnimationWidget extends StatefulWidget {
  const GiftAnimationWidget({super.key});

  @override
  State<GiftAnimationWidget> createState() => _GiftAnimationWidgetState();
}

class _GiftAnimationWidgetState extends State<GiftAnimationWidget> {
  final GiftController controller = Get.find<GiftController>();
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    // Monitor screen stream layers for incoming animations requests from sockets channels
    ever(controller.activeOverlayGift, (gift) {
      if (gift != null) {
        setState(() {
          _isVisible = true;
        });

        // Auto dismiss local presentation layers after timeout thresholds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _isVisible = false;
            });
            controller.activeOverlayGift.value = null; // Clear stream locks
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Obx(() {
      final gift = controller.activeOverlayGift.value;
      if (gift == null) return const SizedBox.shrink();

      return IgnorePointer(
        // Allow click events to bypass overlay matrices
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: _isVisible ? 1.0 : 0.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Dynamic Rendering Simulation Frame
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xffFF8906).withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Text(
                    gift.icon,
                    style: TextStyle(fontSize: gift.isFullScreen ? 90 : 54),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Alert Badge text strings
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xff15141F).withOpacity(0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xffFF8906).withOpacity(0.3)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: "Arvind ",
                            style: TextStyle(
                                color: Color(0xffFF8906),
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        const TextSpan(
                            text: "sent ",
                            style:
                                TextStyle(color: Colors.white, fontSize: 13)),
                        TextSpan(
                            text: gift.name,
                            style: const TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        TextSpan(
                          text:
                              "  x${controller.activeComboMultiplier.value} 🚀",
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
