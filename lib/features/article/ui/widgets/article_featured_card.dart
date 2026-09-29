import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/article_item.dart';

class ArticleFeaturedCard extends StatelessWidget {
  const ArticleFeaturedCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final ArticleItem article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border, width: 1.8),
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
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover Photo with Gradient Overlay
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.2)),
                child: Stack(
                  children: [
                    if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: article.imageUrl!,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 180,
                          color: AppTheme.primary,
                          child: const Icon(Icons.newspaper, color: Colors.white, size: 40),
                        ),
                      )
                    else
                      Container(
                        height: 180,
                        width: double.infinity,
                        color: AppTheme.primary,
                        child: const Icon(Icons.newspaper, color: Colors.white, size: 48),
                      ),

                    // Top Badge: Sorotan Utama
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primary, width: 1.5),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.primary,
                              offset: Offset(1.5, 1.5),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '⭐ SOROTAN UTAMA',
                              style: TextStyle(
                                color: AppTheme.primary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Category Pill on Right
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textOnsurface,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    if (article.summary != null && article.summary!.trim().isNotEmpty) ...[
                      Text(
                        article.summary!,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: AppTheme.textMuted,
                          height: 1.45,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Footer Action Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule, size: 13, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${article.readingTimeMinutes} mnt baca',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
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
                                fontSize: 11.5,
                                color: AppTheme.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primary,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.border, width: 1.2),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Baca',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward, size: 12, color: Colors.white),
                            ],
                          ),
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
