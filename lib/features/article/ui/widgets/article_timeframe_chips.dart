import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../logic/article_controller.dart';

class ArticleTimeframeChips extends StatelessWidget {
  const ArticleTimeframeChips({
    super.key,
    required this.selectedTimeframe,
    required this.onSelectTimeframe,
    required this.unreadOnly,
    required this.onToggleUnreadOnly,
  });

  final String selectedTimeframe;
  final ValueChanged<String> onSelectTimeframe;
  final bool unreadOnly;
  final VoidCallback onToggleUnreadOnly;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Filter Belum Dibaca Toggle Button
          GestureDetector(
            onTap: onToggleUnreadOnly,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
              decoration: BoxDecoration(
                color: unreadOnly ? const Color(0xFFFEF3C7) : AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unreadOnly ? const Color(0xFFB45309) : AppTheme.border,
                  width: unreadOnly ? 1.6 : 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: unreadOnly ? const Color(0xFFB45309).withValues(alpha: 0.3) : AppTheme.border,
                    offset: const Offset(1.5, 1.5),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    unreadOnly ? Icons.mark_email_unread : Icons.mark_email_unread_outlined,
                    size: 13,
                    color: unreadOnly ? const Color(0xFFB45309) : AppTheme.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'Belum Dibaca',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: unreadOnly ? FontWeight.w800 : FontWeight.w600,
                      color: unreadOnly ? const Color(0xFFB45309) : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Divider pill
          Container(
            height: 18,
            width: 1.5,
            color: AppTheme.border,
            margin: const EdgeInsets.only(right: 8),
          ),

          // Timeframe Chips (Semua Waktu, Hari Ini, Bulan Ini, Top News)
          ...ArticleController.timeframes.map((tf) {
            final isSelected = selectedTimeframe == tf;
            return GestureDetector(
              onTap: () => onSelectTimeframe(tf),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                    width: isSelected ? 1.6 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected ? AppTheme.primary.withValues(alpha: 0.3) : AppTheme.border,
                      offset: const Offset(1.5, 1.5),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Text(
                  tf,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.textMuted,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
