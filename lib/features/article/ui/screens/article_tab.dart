import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/system_response_dialog.dart';
import '../../data/models/article_item.dart';
import '../../logic/article_controller.dart';
import '../widgets/article_card.dart';
import '../widgets/article_carousel_slider.dart';
import '../widgets/article_category_chip.dart';
import '../widgets/article_timeframe_chips.dart';
import 'article_detail_screen.dart';

class ArticleTab extends StatefulWidget {
  const ArticleTab({super.key});

  @override
  State<ArticleTab> createState() => _ArticleTabState();
}

class _ArticleTabState extends State<ArticleTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ArticleController>();
      if (controller.articles.isEmpty && !controller.isLoading) {
        controller.fetchArticles();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ArticleController>().loadMore();
    }
  }

  void _openDetail(ArticleItem article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ArticleDetailScreen(initialArticle: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ArticleController>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Sticky Header & Filter Area
            _buildTopHeader(context, controller),

            // Main Content Area with Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                color: AppTheme.primary,
                backgroundColor: AppTheme.surface,
                onRefresh: () => controller.fetchArticles(isRefresh: true),
                child: _buildBody(context, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, ArticleController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppTheme.border, width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 3),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Total Badge Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppTheme.secondary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.primary, width: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Kabar & Edukasi',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Informasi aksesibilitas & fasilitas inklusif Sleman',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              if (controller.meta != null && controller.meta!.total > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border, width: 1.2),
                  ),
                  child: Text(
                    '${controller.meta!.total} Artikel',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Search Bar Neobrutalism
          Container(
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.border,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: controller.onSearchChanged,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textOnsurface,
              ),
              decoration: InputDecoration(
                hintText: 'Cari topik, regulasi, fasilitas...',
                hintStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textMuted,
                ),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          controller.clearSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Category Chips Horizontal Scroll
          SizedBox(
            height: 34,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: ArticleController.categories.length,
              itemBuilder: (context, index) {
                final cat = ArticleController.categories[index];
                final isSelected = controller.selectedCategory == cat;
                return ArticleCategoryChip(
                  label: cat,
                  isSelected: isSelected,
                  onTap: () => controller.setCategory(cat),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Timeframe & Unread Chips Row
          ArticleTimeframeChips(
            selectedTimeframe: controller.selectedTimeframe,
            onSelectTimeframe: controller.setTimeframe,
            unreadOnly: controller.filterUnreadOnly,
            onToggleUnreadOnly: controller.toggleFilterUnreadOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, ArticleController controller) {
    if (controller.isLoading && controller.articles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primary),
            SizedBox(height: 12),
            Text(
              'Memuat kabar edukasi...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    if (controller.errorMessage != null && controller.articles.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SystemResponseDialog.error(
                title: 'Gagal Memuat Berita',
                description: controller.errorMessage!,
                buttonText: 'Coba Lagi',
                onButtonPressed: () => controller.fetchArticles(),
              ),
            ],
          ),
        ),
      );
    }

    final displayed = controller.displayedArticles;

    if (displayed.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SystemResponseDialog.success(
            title: 'Kabar Tidak Ditemukan',
            description: controller.filterUnreadOnly
                ? 'Seluruh artikel pada kategori atau rentang waktu ini telah Anda baca.'
                : (controller.searchQuery.isNotEmpty
                    ? 'Tidak ada artikel yang cocok dengan kata kunci "${controller.searchQuery}".'
                    : 'Belum ada artikel yang dipublikasikan pada filter waktu ini.'),
            buttonText: 'Tampilkan Semua Berita',
            imagePath: 'public/maskot-genit.svg',
            onButtonPressed: () {
              _searchController.clear();
              controller.clearSearch();
              controller.setCategory('Semua');
              controller.setTimeframe('Semua Waktu');
              if (controller.filterUnreadOnly) controller.toggleFilterUnreadOnly();
            },
          ),
        ),
      );
    }

    final showCarousel = controller.selectedTimeframe == 'Semua Waktu' &&
        controller.searchQuery.isEmpty &&
        controller.selectedCategory == 'Semua' &&
        !controller.filterUnreadOnly &&
        controller.carouselArticles.isNotEmpty;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      children: [
        // 1. Auto-Slide Carousel Slider (Berita Pilihan Hari Ini)
        if (showCarousel) ...[
          ArticleCarouselSlider(
            articles: controller.carouselArticles,
            onTap: _openDetail,
            isArticleRead: controller.isArticleRead,
          ),
          const SizedBox(height: 18),
        ],

        // 2. Section Header: Sesuai filter waktu
        _buildSectionHeader(controller),
        const SizedBox(height: 12),

        // 3. List of Article Cards
        ...displayed.map((article) {
          final isRead = controller.isArticleRead(article.id);
          return ArticleCard(
            article: article,
            isRead: isRead,
            onTap: () => _openDetail(article),
            onToggleRead: () => controller.toggleReadStatus(article.id),
          );
        }),

        // 4. Loading More Indicator
        if (controller.isLoadingMore)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(ArticleController controller) {
    String title = 'Seluruh Berita & Edukasi';
    IconData icon = Icons.newspaper;

    if (controller.selectedTimeframe == 'Hari Ini') {
      title = 'Kabar Hari Ini';
      icon = Icons.today;
    } else if (controller.selectedTimeframe == 'Bulan Ini') {
      title = 'Sorotan Bulan Ini';
      icon = Icons.calendar_month;
    } else if (controller.selectedTimeframe == '🔥 Top News') {
      title = 'Berita Terpopuler';
      icon = Icons.local_fire_department;
    } else if (controller.filterUnreadOnly) {
      title = 'Berita Belum Dibaca';
      icon = Icons.mark_email_unread;
    }

    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        Text(
          '${controller.displayedArticles.length} artikel',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
