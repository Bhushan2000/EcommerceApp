import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../utils/constants.dart';

class CategoryChip extends StatefulWidget {
  final CategoryModel category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? AppColors.primaryGradient : null,
            color: widget.isSelected
                ? null
                : (isDark ? AppColors.cardDark : Colors.white),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
              width: 1.2,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(70),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 20 : 6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? Colors.white.withAlpha(45)
                      : (isDark
                          ? Colors.white.withAlpha(15)
                          : AppColors.primary.withAlpha(20)),
                ),
                child: Icon(
                  widget.category.iconData,
                  size: 15,
                  color: widget.isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey.shade300 : AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.category.name,
                style: TextStyle(
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.1,
                  color: widget.isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
