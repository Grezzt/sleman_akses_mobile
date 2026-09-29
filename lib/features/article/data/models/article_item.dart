class ArticleItem {
  const ArticleItem({
    required this.id,
    required this.title,
    required this.slug,
    this.summary,
    this.content,
    required this.category,
    this.detectedFacilities = const [],
    this.imageUrl,
    this.authorName,
    this.sourceName,
    this.sourceUrl,
    this.isScraped = false,
    this.aiProcessed = false,
    this.publishedAt,
    this.viewsCount = 0,
    this.readingTimeMinutes = 1,
  });

  factory ArticleItem.fromJson(Map<String, dynamic> json) {
    List<String> parseFacilities(dynamic raw) {
      if (raw is List) {
        return raw.map((e) => e.toString()).toList();
      }
      return const [];
    }

    DateTime? parseDate(dynamic raw) {
      if (raw is String && raw.isNotEmpty) {
        return DateTime.tryParse(raw);
      }
      return null;
    }

    return ArticleItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      summary: json['summary'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String? ?? 'Aksesibilitas',
      detectedFacilities: parseFacilities(json['detected_facilities']),
      imageUrl: json['image_url'] as String?,
      authorName: json['author_name'] as String?,
      sourceName: json['source_name'] as String?,
      sourceUrl: json['source_url'] as String?,
      isScraped: json['is_scraped'] as bool? ?? false,
      aiProcessed: json['ai_processed'] as bool? ?? false,
      publishedAt: parseDate(json['published_at']),
      viewsCount: json['views_count'] as int? ?? 0,
      readingTimeMinutes: json['reading_time_minutes'] as int? ?? 1,
    );
  }

  final int id;
  final String title;
  final String slug;
  final String? summary;
  final String? content;
  final String category;
  final List<String> detectedFacilities;
  final String? imageUrl;
  final String? authorName;
  final String? sourceName;
  final String? sourceUrl;
  final bool isScraped;
  final bool aiProcessed;
  final DateTime? publishedAt;
  final int viewsCount;
  final int readingTimeMinutes;

  String get authorOrSource {
    if (authorName != null && authorName!.trim().isNotEmpty) {
      return authorName!.trim();
    }
    if (sourceName != null && sourceName!.trim().isNotEmpty) {
      return sourceName!.trim();
    }
    return 'Tim Editorial Sleman Akses';
  }

  String get formattedPublishedDate {
    if (publishedAt == null) return 'Baru Saja';
    final now = DateTime.now();
    final diff = now.difference(publishedAt!);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes <= 1 ? 1 : diff.inMinutes} mnt yang lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = publishedAt!.day;
    final month = months[publishedAt!.month - 1];
    final year = publishedAt!.year;
    return '$day $month $year';
  }

  ArticleItem copyWith({
    int? id,
    String? title,
    String? slug,
    String? summary,
    String? content,
    String? category,
    List<String>? detectedFacilities,
    String? imageUrl,
    String? authorName,
    String? sourceName,
    String? sourceUrl,
    bool? isScraped,
    bool? aiProcessed,
    DateTime? publishedAt,
    int? viewsCount,
    int? readingTimeMinutes,
  }) {
    return ArticleItem(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      category: category ?? this.category,
      detectedFacilities: detectedFacilities ?? this.detectedFacilities,
      imageUrl: imageUrl ?? this.imageUrl,
      authorName: authorName ?? this.authorName,
      sourceName: sourceName ?? this.sourceName,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      isScraped: isScraped ?? this.isScraped,
      aiProcessed: aiProcessed ?? this.aiProcessed,
      publishedAt: publishedAt ?? this.publishedAt,
      viewsCount: viewsCount ?? this.viewsCount,
      readingTimeMinutes: readingTimeMinutes ?? this.readingTimeMinutes,
    );
  }
}
