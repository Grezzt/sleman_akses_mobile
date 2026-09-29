import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/article_item.dart';
import '../../logic/article_controller.dart';
import '../../logic/article_tts_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.initialArticle,
  });

  final ArticleItem initialArticle;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late ArticleItem _article;
  late final ArticleTtsService _ttsService;
  bool _isLoadingContent = false;
  final List<GlobalKey> _paragraphKeys = [];
  final GlobalKey _summaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _article = widget.initialArticle;
    _ttsService = ArticleTtsService();
    _ttsService.addListener(_onTtsStateChanged);

    // Auto mark article as read on initial open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ArticleController>().markAsRead(_article.id);
    });

    // If full content is not loaded, fetch it from API
    if (_article.content == null || _article.content!.isEmpty) {
      _loadFullDetail();
    }
  }

  @override
  void dispose() {
    _ttsService.removeListener(_onTtsStateChanged);
    _ttsService.dispose();
    super.dispose();
  }

  void _onTtsStateChanged() {
    if (!mounted) return;
    setState(() {});

    // Auto scroll to active paragraph
    if (_ttsService.isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final activeKey = _resolveActiveKey();
        if (activeKey != null && activeKey.currentContext != null) {
          Scrollable.ensureVisible(
            activeKey.currentContext!,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            alignment: 0.35,
          );
        }
      });
    }
  }

  GlobalKey? _resolveActiveKey() {
    if (_ttsService.isSummaryIncluded) {
      if (_ttsService.currentIndex == 0) {
        return _summaryKey;
      }
      final paraIdx = _ttsService.currentIndex - 1;
      if (paraIdx >= 0 && paraIdx < _paragraphKeys.length) {
        return _paragraphKeys[paraIdx];
      }
    } else {
      final paraIdx = _ttsService.currentIndex;
      if (paraIdx >= 0 && paraIdx < _paragraphKeys.length) {
        return _paragraphKeys[paraIdx];
      }
    }
    return null;
  }

  List<String> _extractParagraphs() {
    final rawContent = _article.content ?? _article.summary ?? '';
    if (rawContent.trim().isEmpty) return [];

    return rawContent
        .replaceAll(RegExp(r'</?(p|div|br)[^>]*>', caseSensitive: false), '\n\n')
        .split(RegExp(r'(\r\n){2,}|\r{2,}|\n{2,}'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
  }

  void _toggleTtsPlayback() {
    if (_ttsService.isPlaying) {
      _ttsService.pause();
    } else if (_ttsService.isPaused) {
      _ttsService.resume();
    } else {
      final paragraphs = _extractParagraphs();
      _ttsService.startReading(
        summary: _article.summary,
        paragraphs: paragraphs,
      );
    }
  }

  Future<void> _loadFullDetail() async {
    setState(() {
      _isLoadingContent = true;
    });

    final controller = context.read<ArticleController>();
    final full = await controller.fetchDetail(_article.slug.isNotEmpty ? _article.slug : _article.id);

    if (mounted && full != null) {
      setState(() {
        _article = full;
        _isLoadingContent = false;
      });
    } else if (mounted) {
      setState(() {
        _isLoadingContent = false;
      });
    }
  }

  Future<void> _openSourceUrl() async {
    final rawUrl = _article.sourceUrl;
    if (rawUrl == null || rawUrl.trim().isEmpty) return;

    final uri = Uri.tryParse(rawUrl.trim());
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tidak dapat membuka tautan sumber asli.')),
          );
        }
      }
    }
  }

  void _shareArticle() {
    final text = '${_article.title}\nBaca selengkapnya di Sleman Akses: https://sleman-akses.id/berita/${_article.slug}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.primary,
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.secondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Tautan artikel berhasil disalin!',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

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
    if (facility == 'Ramp') return '♿ Jalur Ramp Kursi Roda';
    if (facility == 'Toilet Disabilitas') return '🚻 Toilet Aksesibel Difabel';
    if (facility == 'Parkir Khusus') return '🅿️ Area Parkir Difabel';
    if (facility == 'Lift') return '🛗 Lift Ramah Disabilitas';
    if (facility == 'Guiding Block') return '🦯 Guiding Block Tunanetra';
    return '♿ $facility';
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ArticleController>();
    final isRead = controller.isArticleRead(_article.id);
    final catColor = _resolveCategoryColors(_article.category);
    final paragraphs = _extractParagraphs();

    // Rebuild paragraph keys array to match paragraph count
    if (_paragraphKeys.length != paragraphs.length) {
      _paragraphKeys.clear();
      for (var i = 0; i < paragraphs.length; i++) {
        _paragraphKeys.add(GlobalKey());
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        foregroundColor: AppTheme.textOnsurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Detail Kabar',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppTheme.textOnsurface,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border, width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: AppTheme.border,
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 18, color: AppTheme.primary),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        actions: [
          // Toggle Read / Unread Status Button
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isRead ? const Color(0xFFECFDF5) : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRead ? AppTheme.primary : AppTheme.border,
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.border,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isRead ? Icons.bookmark : Icons.bookmark_border,
                  size: 18,
                  color: isRead ? AppTheme.primary : AppTheme.textMuted,
                ),
                onPressed: () {
                  controller.toggleReadStatus(_article.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      content: Text(
                        !isRead ? 'Ditandai sebagai Sudah Dibaca' : 'Ditandai sebagai Belum Dibaca',
                      ),
                    ),
                  );
                },
                padding: EdgeInsets.zero,
                tooltip: isRead ? 'Tandai Belum Dibaca' : 'Tandai Sudah Dibaca',
              ),
            ),
          ),
          // Share Button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: AppTheme.border,
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.share, size: 17, color: AppTheme.primary),
                onPressed: _shareArticle,
                padding: EdgeInsets.zero,
                tooltip: 'Bagikan Berita',
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.5),
          child: Divider(color: AppTheme.border, height: 1.5, thickness: 1.5),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Photo Hero
            if (_article.imageUrl != null && _article.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: _article.imageUrl!,
                    height: 230,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 230,
                      color: Colors.grey.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppTheme.primary),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 230,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported, size: 40),
                    ),
                  ),
                  if (_article.sourceName != null && _article.sourceName!.isNotEmpty)
                    Positioned(
                      bottom: 8,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Kredit: ${_article.sourceName}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

            // Article Content Wrapper
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Row: Category, Reading Time, Views
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                        decoration: BoxDecoration(
                          color: catColor.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: catColor.border, width: 1.2),
                        ),
                        child: Text(
                          _article.category,
                          style: TextStyle(
                            color: catColor.text,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.border, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.schedule, size: 12, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${_article.readingTimeMinutes} mnt baca',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_article.viewsCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.border, width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.visibility, size: 12, color: AppTheme.textMuted),
                              const SizedBox(width: 4),
                              Text(
                                '${_article.viewsCount} dilihat',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Article Title
                  Text(
                    _article.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Author & Date Bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppTheme.border, width: 1.2),
                        bottom: BorderSide(color: AppTheme.border, width: 1.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppTheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary, width: 1.5),
                          ),
                          child: const Icon(Icons.person, color: AppTheme.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _article.authorOrSource,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textOnsurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_article.formattedPublishedDate} • Wilayah Sleman',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- Audio Reader (Text-to-Speech) Neobrutalism Toolbar ---
                  _buildTtsToolbar(),

                  const SizedBox(height: 20),

                  // Lead Summary Box
                  if (_article.summary != null && _article.summary!.trim().isNotEmpty) ...[
                    _buildLeadSummaryBox(),
                    const SizedBox(height: 22),
                  ],

                  // Formatted Content Body with Highlightable Paragraphs
                  _buildContentBody(paragraphs),

                  const SizedBox(height: 24),

                  // Detected Facilities Box
                  if (_article.detectedFacilities.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.border, width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                            color: AppTheme.border,
                            offset: Offset(3, 3),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.accessible, color: AppTheme.primary, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Fasilitas Difabel Terkait',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.textOnsurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Artikel ini memuat pembahasan mengenai sarana dan prasarana aksesibilitas fisik:',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: _article.detectedFacilities.map((f) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.border, width: 1.2),
                                ),
                                child: Text(
                                  _formatFacility(f),
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Source URL Link Button
                  if (_article.sourceUrl != null && _article.sourceUrl!.trim().isNotEmpty) ...[
                    GestureDetector(
                      onTap: _openSourceUrl,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: AppTheme.primary, width: 1.8),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.border,
                              offset: Offset(3, 3),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.open_in_new, size: 16, color: AppTheme.primary),
                            SizedBox(width: 8),
                            Text(
                              'Kunjungi Sumber Asli Berita',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTtsToolbar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border, width: 1.8),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.border,
            offset: Offset(3.5, 3.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border, width: 1.2),
                ),
                child: Icon(
                  _ttsService.isPlaying ? Icons.volume_up : Icons.volume_mute,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AUDIO READER (TTS)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _ttsService.statusText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Play / Pause Button
              GestureDetector(
                onTap: _toggleTtsPlayback,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _ttsService.isPlaying ? const Color(0xFFD97706) : AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border, width: 1.4),
                    boxShadow: const [
                      BoxShadow(
                        color: AppTheme.border,
                        offset: Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _ttsService.isPlaying
                            ? Icons.pause
                            : (_ttsService.isPaused ? Icons.play_arrow : Icons.headphones),
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _ttsService.isPlaying
                            ? 'Jeda'
                            : (_ttsService.isPaused ? 'Lanjut' : 'Dengarkan'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!_ttsService.isStopped) ...[
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.stop, color: AppTheme.error, size: 22),
                  onPressed: () => _ttsService.stop(),
                  tooltip: 'Berhenti',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ],
          ),

          // Speed Multipliers Selector Row
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppTheme.border),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Kecepatan Suara:',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textMuted,
                ),
              ),
              Row(
                children: [0.8, 1.0, 1.2].map((speed) {
                  final isCurrentSpeed = _ttsService.speedMultiplier == speed;
                  return GestureDetector(
                    onTap: () => _ttsService.setSpeed(speed),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isCurrentSpeed ? AppTheme.primary : AppTheme.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isCurrentSpeed ? AppTheme.primary : AppTheme.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '${speed}x',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isCurrentSpeed ? Colors.white : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeadSummaryBox() {
    final isSummaryActive = _ttsService.isPlaying &&
        _ttsService.isSummaryIncluded &&
        _ttsService.currentIndex == 0;

    return GestureDetector(
      key: _summaryKey,
      onTap: () {
        final paragraphs = _extractParagraphs();
        _ttsService.startReading(
          summary: _article.summary,
          paragraphs: paragraphs,
          startIndex: 0,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSummaryActive ? const Color(0xFFFEF08A) : const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSummaryActive ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.4),
            width: isSummaryActive ? 2.5 : 1.6,
          ),
          boxShadow: [
            BoxShadow(
              color: isSummaryActive ? AppTheme.primary.withValues(alpha: 0.2) : AppTheme.border,
              offset: const Offset(3, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1.5),
              ),
              child: const Icon(Icons.lightbulb, color: AppTheme.secondary, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'RINGKASAN WAWASAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      if (isSummaryActive)
                        const Row(
                          children: [
                            Icon(Icons.volume_up, size: 14, color: AppTheme.primary),
                            SizedBox(width: 4),
                            Text(
                              'Sedang dibaca',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _article.summary!,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF022C22),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentBody(List<String> paragraphs) {
    if (_isLoadingContent) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.primary),
              SizedBox(height: 10),
              Text(
                'Memuat seluruh isi artikel...',
                style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    if (paragraphs.isEmpty) {
      return const Text(
        'Konten artikel belum tersedia.',
        style: TextStyle(color: AppTheme.textMuted, fontStyle: FontStyle.italic),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(paragraphs.length, (idx) {
        final para = paragraphs[idx];
        final segmentIndex = _ttsService.isSummaryIncluded ? idx + 1 : idx;
        final isParaActive = _ttsService.isPlaying && _ttsService.currentIndex == segmentIndex;

        return GestureDetector(
          key: _paragraphKeys.length > idx ? _paragraphKeys[idx] : null,
          onTap: () {
            _ttsService.startReading(
              summary: _article.summary,
              paragraphs: paragraphs,
              startIndex: segmentIndex,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 14),
            padding: isParaActive
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : EdgeInsets.zero,
            decoration: isParaActive
                ? BoxDecoration(
                    color: const Color(0xFFFEF08A),
                    border: const Border(
                      left: BorderSide(color: AppTheme.primary, width: 4.5),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  )
                : null,
            child: Text(
              para,
              style: TextStyle(
                fontSize: 15,
                height: 1.7,
                color: AppTheme.textOnsurface,
                fontWeight: isParaActive ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.1,
              ),
            ),
          ),
        );
      }),
    );
  }
}
