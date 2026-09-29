import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sleman_akses_mobile/features/article/data/datasources/article_local_data_source.dart';
import 'package:sleman_akses_mobile/features/article/data/models/article_item.dart';

void main() {
  group('Article Advanced Features Test', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('ArticleLocalDataSource correctly toggles read and unread status', () async {
      final dataSource = ArticleLocalDataSource();

      // Initially empty
      var readIds = await dataSource.getReadArticleIds();
      expect(readIds, isEmpty);

      // Mark as read
      await dataSource.markArticleAsRead(101);
      readIds = await dataSource.getReadArticleIds();
      expect(readIds, contains(101));

      // Toggle status (from read to unread)
      final nowRead1 = await dataSource.toggleReadStatus(101);
      expect(nowRead1, isFalse);
      readIds = await dataSource.getReadArticleIds();
      expect(readIds, isNot(contains(101)));

      // Toggle status again (from unread to read)
      final nowRead2 = await dataSource.toggleReadStatus(101);
      expect(nowRead2, isTrue);
      readIds = await dataSource.getReadArticleIds();
      expect(readIds, contains(101));

      // Mark as unread
      await dataSource.markArticleAsUnread(101);
      readIds = await dataSource.getReadArticleIds();
      expect(readIds, isEmpty);
    });

    test('ArticleItem sorting by views_count (Top News)', () {
      final a1 = const ArticleItem(
        id: 1,
        title: 'Artikel 1',
        slug: 'a-1',
        category: 'Aksesibilitas',
        viewsCount: 15,
      );
      final a2 = const ArticleItem(
        id: 2,
        title: 'Artikel 2',
        slug: 'a-2',
        category: 'Aksesibilitas',
        viewsCount: 150,
      );
      final a3 = const ArticleItem(
        id: 3,
        title: 'Artikel 3',
        slug: 'a-3',
        category: 'Aksesibilitas',
        viewsCount: 45,
      );

      final list = [a1, a2, a3];
      list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

      expect(list.map((a) => a.id).toList(), [2, 3, 1]);
    });
  });
}
