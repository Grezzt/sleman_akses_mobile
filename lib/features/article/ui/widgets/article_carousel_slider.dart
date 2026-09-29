import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/article_item.dart';

class ArticleCarouselSlider extends StatefulWidget {
  const ArticleCarouselSlider({
    super.key,
    required this.articles,
    required this.onTap,
    required this.isArticleRead,
  });

  final List<ArticleItem> articles;
  final ValueChanged<ArticleItem> onTap;
  final bool Function(int id) isArticleRead;

  @override
  State<ArticleCarouselSlider> createState() => _ArticleCarouselSliderState();
}

class _ArticleCarouselSliderState extends State<ArticleCarouselSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant ArticleCarouselSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.articles.length != widget.articles.length) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (widget.articles.length <= 1) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final next = (_currentPage + 1) % widget.articles.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.articles.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.articles.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final article = widget.articles[index];
              final isRead = widget.isArticleRead(article.id);

              return GestureDetector(
                onTap: () => widget.onTap(article),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.border, width: 1.8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.border,
                        offset: Offset(3.5, 3.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Background Photo
                        if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            height: double.infinity,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(color: Colors.grey.shade200),
                            errorWidget: (context, url, error) => Container(color: AppTheme.primary),
                          )
                        else
                          Container(color: AppTheme.primary),

                        // Gradient Overlay for text contrast
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.15),
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Top Badges Row
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.secondary,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.primary, width: 1.4),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: AppTheme.primary,
                                      offset: Offset(1.5, 1.5),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '⭐ PILIHAN HARI INI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: AppTheme.primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              if (isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: AppTheme.secondary, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sudah Dibaca',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Bottom Title & Meta
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    article.category,
                                    style: const TextStyle(
                                      color: AppTheme.secondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text('•', style: TextStyle(color: Colors.white70)),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${article.readingTimeMinutes} mnt baca',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (article.viewsCount > 0) ...[
                                    const SizedBox(width: 6),
                                    const Text('•', style: TextStyle(color: Colors.white70)),
                                    const SizedBox(width: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.visibility, color: Colors.white70, size: 11),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${article.viewsCount}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
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
            },
          ),
        ),

        // Dot Indicators
        if (widget.articles.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.articles.length, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 22 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive ? AppTheme.primary : AppTheme.border,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isActive ? AppTheme.primary : AppTheme.border,
                    width: 1,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
