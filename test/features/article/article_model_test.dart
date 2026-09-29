import 'package:flutter_test/flutter_test.dart';
import 'package:sleman_akses_mobile/features/article/data/models/article_item.dart';
import 'package:sleman_akses_mobile/features/article/data/models/article_pagination_meta.dart';

void main() {
  group('ArticleItem Model Test', () {
    test('fromJson correctly parses complete JSON payload', () {
      final json = {
        'id': 101,
        'title': 'Peningkatan Aksesibilitas Trotoar Sleman',
        'slug': 'peningkatan-aksesibilitas-trotoar-sleman',
        'summary': 'Pemkab Sleman merevitalisasi jalur pedestrian ramah difabel.',
        'content': 'Paragraf pertama isi berita.\n\nParagraf kedua isi berita.',
        'category': 'Aksesibilitas',
        'detected_facilities': ['Ramp', 'Guiding Block', 'Toilet Disabilitas'],
        'image_url': 'https://example.com/photo.jpg',
        'author_name': 'Dinas PUPKP Sleman',
        'source_name': 'Harian Jogja',
        'source_url': 'https://harianjogja.com/trotoar',
        'is_scraped': false,
        'ai_processed': true,
        'published_at': '2026-09-29T08:00:00.000Z',
        'views_count': 125,
        'reading_time_minutes': 4,
      };

      final article = ArticleItem.fromJson(json);

      expect(article.id, 101);
      expect(article.title, 'Peningkatan Aksesibilitas Trotoar Sleman');
      expect(article.slug, 'peningkatan-aksesibilitas-trotoar-sleman');
      expect(article.summary, 'Pemkab Sleman merevitalisasi jalur pedestrian ramah difabel.');
      expect(article.content, 'Paragraf pertama isi berita.\n\nParagraf kedua isi berita.');
      expect(article.category, 'Aksesibilitas');
      expect(article.detectedFacilities, ['Ramp', 'Guiding Block', 'Toilet Disabilitas']);
      expect(article.imageUrl, 'https://example.com/photo.jpg');
      expect(article.authorName, 'Dinas PUPKP Sleman');
      expect(article.sourceName, 'Harian Jogja');
      expect(article.sourceUrl, 'https://harianjogja.com/trotoar');
      expect(article.isScraped, false);
      expect(article.aiProcessed, true);
      expect(article.viewsCount, 125);
      expect(article.readingTimeMinutes, 4);
      expect(article.authorOrSource, 'Dinas PUPKP Sleman');
    });

    test('fromJson gracefully handles empty and null fields', () {
      final json = {
        'id': 202,
        'title': 'Berita Singkat',
        'slug': 'berita-singkat',
        'category': null,
      };

      final article = ArticleItem.fromJson(json);

      expect(article.id, 202);
      expect(article.title, 'Berita Singkat');
      expect(article.summary, isNull);
      expect(article.content, isNull);
      expect(article.category, 'Aksesibilitas');
      expect(article.detectedFacilities, isEmpty);
      expect(article.imageUrl, isNull);
      expect(article.authorOrSource, 'Tim Editorial Sleman Akses');
      expect(article.viewsCount, 0);
      expect(article.readingTimeMinutes, 1);
    });

    test('ArticlePaginationMeta parses pagination structure', () {
      final json = {
        'current_page': 1,
        'last_page': 3,
        'per_page': 10,
        'total': 25,
      };

      final meta = ArticlePaginationMeta.fromJson(json);

      expect(meta.currentPage, 1);
      expect(meta.lastPage, 3);
      expect(meta.perPage, 10);
      expect(meta.total, 25);
      expect(meta.hasMore, isTrue);
    });
  });
}
