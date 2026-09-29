import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class ArticleCategoryChip extends StatelessWidget {
  const ArticleCategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 1.8 : 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppTheme.primary.withValues(alpha: 0.25) : AppTheme.border,
              offset: isSelected ? const Offset(2, 2) : const Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primary : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12.5,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
