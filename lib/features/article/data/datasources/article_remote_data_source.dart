import 'dart:convert';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/network/api_client.dart';
import '../models/article_item.dart';
import '../models/article_pagination_meta.dart';

class ArticleRemoteDataSource {
  Future<({List<ArticleItem> articles, ArticlePaginationMeta meta})> getArticles({
    int page = 1,
    int perPage = 10,
    String? category,
    String? search,
  }) async {
    ApiClient.ensureBaseUrl();

    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };

    if (category != null && category.trim().isNotEmpty && category != 'Semua') {
      queryParams['category'] = category.trim();
    }

    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('${ApiClient.baseUrl}/news').replace(queryParameters: queryParams);

    final response = await ApiClient.client.get(
      uri,
      headers: ApiClient.headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _decodeBody(response.body);
      final rawData = body['data'];
      final rawMeta = body['meta'];

      final articles = (rawData is List)
          ? rawData
              .whereType<Map<String, dynamic>>()
              .map(ArticleItem.fromJson)
              .toList()
          : <ArticleItem>[];

      final meta = (rawMeta is Map<String, dynamic>)
          ? ArticlePaginationMeta.fromJson(rawMeta)
          : ArticlePaginationMeta(
              currentPage: page,
              lastPage: 1,
              perPage: perPage,
              total: articles.length,
            );

      return (articles: articles, meta: meta);
    }

    final body = _decodeBody(response.body);
    throw ApiException(
      body['message']?.toString() ?? 'Gagal memuat berita.',
      fieldErrors: _parseErrors(body),
    );
  }

  Future<ArticleItem> getArticleDetail(dynamic idOrSlug) async {
    ApiClient.ensureBaseUrl();

    final uri = Uri.parse('${ApiClient.baseUrl}/news/$idOrSlug');

    final response = await ApiClient.client.get(
      uri,
      headers: ApiClient.headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = _decodeBody(response.body);
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return ArticleItem.fromJson(data);
      }
      throw ApiException('Format detail artikel tidak valid.');
    }

    final body = _decodeBody(response.body);
    throw ApiException(
      body['message']?.toString() ?? 'Berita tidak ditemukan.',
      fieldErrors: _parseErrors(body),
    );
  }

  Map<String, dynamic> _decodeBody(String body) {
    if (body.isEmpty) return {};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {};
  }

  Map<String, List<String>> _parseErrors(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is! Map<String, dynamic>) return {};

    final parsed = <String, List<String>>{};
    for (final entry in errors.entries) {
      final value = entry.value;
      if (value is List) {
        parsed[entry.key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        parsed[entry.key] = [value.toString()];
      }
    }
    return parsed;
  }
}
