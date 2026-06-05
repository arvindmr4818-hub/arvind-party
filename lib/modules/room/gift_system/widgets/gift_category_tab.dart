import 'package:flutter/material.dart';
import '../models/gift_category_model.dart';

class GiftCategoryTab extends StatelessWidget {
  final GiftCategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const GiftCategoryTab({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xffFF8906).withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xffFF8906) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
