import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/article_item.dart';

class ArticleCard extends StatelessWidget {
  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.isRead = false,
    this.onToggleRead,
  });

  final ArticleItem article;
  final VoidCallback onTap;
  final bool isRead;
  final VoidCallback? onToggleRead;

  ({Color bg, Color text, Color border}) _resolveCategoryColors(String category) {
    switch (category) {
      case 'Aksesibilitas':
        return (
          bg: const Color(0xFFECFDF5),
          text: const Color(0xFF065F46),
          border: const Color(0xFFA7F3D0),
        );
      case 'Regulasi & Kebijakan':
        return (
          bg: const Color(0xFFF3E8FF),
          text: const Color(0xFF6B21A8),
          border: const Color(0xFFDDD6FE),
        );
      case 'Fasilitas Publik':
        return (
          bg: const Color(0xFFFEF3C7),
          text: const Color(0xFF92400E),
          border: const Color(0xFFFDE68A),
        );
      case 'Edukasi & Kesadaran':
        return (
          bg: const Color(0xFFEFF6FF),
          text: const Color(0xFF1E40AF),
          border: const Color(0xFFBFDBFE),
        );
      default:
        return (
          bg: const Color(0xFFF1F5F9),
          text: const Color(0xFF334155),
          border: const Color(0xFFCBD5E1),
        );
    }
  }

  String _formatFacility(String facility) {
    if (facility == 'Ramp') return '♿ Ramp';
    if (facility == 'Toilet Disabilitas') return '🚻 Toilet Difabel';
    if (facility == 'Parkir Khusus') return '🅿️ Parkir Difabel';
    if (facility == 'Lift') return '🛗 Lift Difabel';
    if (facility == 'Guiding Block') return '🦯 Guiding Block';
    return '♿ $facility';
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _resolveCategoryColors(article.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? AppTheme.border.withValues(alpha: 0.7) : AppTheme.border,
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo with Category & Read Status Overlay
              if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14.5)),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        height: 155,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 155,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 155,
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: catColor.bg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: catColor.border, width: 1.2),
                          ),
                          child: Text(
                            article.category,
                            style: TextStyle(
                              color: catColor.text,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            if (article.viewsCount > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.visibility, color: Colors.white, size: 11),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${article.viewsCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            // Quick Read Toggle Button on Photo
                            if (onToggleRead != null)
                              GestureDetector(
                                onTap: onToggleRead,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: isRead ? Colors.black.withValues(alpha: 0.7) : AppTheme.secondary,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isRead ? Colors.white54 : AppTheme.primary,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isRead ? Icons.check_circle : Icons.bookmark_border,
                                        size: 11,
                                        color: isRead ? AppTheme.secondary : AppTheme.primary,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        isRead ? 'Dibaca' : 'Baru',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isRead ? Colors.white : AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Content Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top header row if no photo was present
                    if (article.imageUrl == null || article.imageUrl!.isEmpty)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: catColor.bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: catColor.border, width: 1.2),
                            ),
                            child: Text(
                              article.category,
                              style: TextStyle(
                                color: catColor.text,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (onToggleRead != null)
                            GestureDetector(
                              onTap: onToggleRead,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isRead ? AppTheme.border : const Color(0xFFF59E0B),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isRead ? '✓ Sudah Dibaca' : '• Belum Dibaca',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: isRead ? AppTheme.textMuted : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                    // Title
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: isRead ? AppTheme.textOnsurface.withValues(alpha: 0.75) : AppTheme.textOnsurface,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Summary
                    if (article.summary != null && article.summary!.trim().isNotEmpty) ...[
                      Text(
                        article.summary!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Detected Facilities Chips (if any)
                    if (article.detectedFacilities.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: article.detectedFacilities.take(3).map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Text(
                              _formatFacility(f),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Meta Footer Row (Author, Reading Time, Date, Read toggle)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            article.authorOrSource,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 12, color: AppTheme.textMuted),
                            const SizedBox(width: 3),
                            Text(
                              '${article.readingTimeMinutes} mnt',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              article.formattedPublishedDate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
