// ═══════════════════════════════════════════════════════════════════════════
// FILE: lib/features/home/presentation/widgets/category_grid.dart
// ARVIND PARTY - CATEGORY GRID WIDGET
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../models/home_model.dart';

class CategoryGrid extends StatelessWidget {
  final HomeController controller = Get.find<HomeController>();

  CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categoryModels.isEmpty) return const SizedBox();
      return SizedBox(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: controller.categoryModels.length,
          itemBuilder: (context, index) {
            final category = controller.categoryModels[index];
            return _buildCategoryItem(category);
          },
        ),
      );
    });
  }

  Widget _buildCategoryItem(CategoryModel category) {
    return GestureDetector(
      onTap: () => controller.navigateToCategory(category.id),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Color(int.parse('0xFF${category.colorHex.replaceAll('#', '')}')),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  category.iconUrl,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}