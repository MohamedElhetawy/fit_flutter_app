import 'package:flutter/material.dart';
import 'package:fitx/constants.dart';

/// Horizontal scrolling category filter pills.
class CategoryPills extends StatelessWidget {
  const CategoryPills({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: spaceSm),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: fastDuration,
              curve: defaultCurve,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : surfaceColor,
                borderRadius: BorderRadius.circular(radiusFull),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : surfaceBorder,
                  width: 1,
                ),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1A1A00)
                      : textSecondary,
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
