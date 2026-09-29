import 'datasources/article_local_data_source.dart';
import 'datasources/article_remote_data_source.dart';
import 'models/article_item.dart';
import 'models/article_pagination_meta.dart';

class ArticleRepository {
  ArticleRepository({
    ArticleRemoteDataSource? remoteDataSource,
    ArticleLocalDataSource? localDataSource,
  })  : _remoteDataSource = remoteDataSource ?? ArticleRemoteDataSource(),
        _localDataSource = localDataSource ?? ArticleLocalDataSource();

  final ArticleRemoteDataSource _remoteDataSource;
  final ArticleLocalDataSource _localDataSource;

  Future<({List<ArticleItem> articles, ArticlePaginationMeta meta})> getArticles({
    int page = 1,
    int perPage = 10,
    String? category,
    String? search,
  }) {
    return _remoteDataSource.getArticles(
      page: page,
      perPage: perPage,
      category: category,
      search: search,
    );
  }

  Future<ArticleItem> getArticleDetail(dynamic idOrSlug) {
    return _remoteDataSource.getArticleDetail(idOrSlug);
  }

  Future<Set<int>> getReadArticleIds() {
    return _localDataSource.getReadArticleIds();
  }

  Future<void> markArticleAsRead(int articleId) {
    return _localDataSource.markArticleAsRead(articleId);
  }

  Future<void> markArticleAsUnread(int articleId) {
    return _localDataSource.markArticleAsUnread(articleId);
  }

  Future<bool> toggleReadStatus(int articleId) {
    return _localDataSource.toggleReadStatus(articleId);
  }
}
