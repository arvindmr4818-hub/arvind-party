// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/widgets/banner_slider.dart
// ARVIND PARTY - BANNER SLIDER WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../models/home_model.dart';

class BannerSlider extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.banners.isEmpty) return const SizedBox();
      return SizedBox(
        height: 180,
        child: PageView.builder(
          controller: PageController(viewportFraction: 0.9),
          itemCount: controller.banners.length,
          itemBuilder: (context, index) {
            final banner = controller.banners[index];
            return _buildBannerCard(banner);
          },
        ),
      );
    });
  }

  Widget _buildBannerCard(BannerModel banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: NetworkImage(banner.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                banner.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}