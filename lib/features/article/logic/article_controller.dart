import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/errors/api_exception.dart';
import '../data/article_repository.dart';
import '../data/models/article_item.dart';
import '../data/models/article_pagination_meta.dart';

class ArticleController extends ChangeNotifier {
  ArticleController(this._repository) {
    _loadReadArticleIds();
  }

  final ArticleRepository _repository;

  static const List<String> categories = [
    'Semua',
    'Aksesibilitas',
    'Regulasi & Kebijakan',
    'Fasilitas Publik',
    'Edukasi & Kesadaran',
  ];

  static const List<String> timeframes = [
    'Semua Waktu',
    'Hari Ini',
    'Bulan Ini',
    '🔥 Top News',
  ];

  List<ArticleItem> _articles = [];
  ArticlePaginationMeta? _meta;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  String _selectedCategory = 'Semua';
  String _selectedTimeframe = 'Semua Waktu';
  bool _filterUnreadOnly = false;
  String _searchQuery = '';
  Timer? _debounceTimer;

  Set<int> _readArticleIds = {};

  // Getters
  List<ArticleItem> get articles => _articles;
  ArticlePaginationMeta? get meta => _meta;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  String get selectedTimeframe => _selectedTimeframe;
  bool get filterUnreadOnly => _filterUnreadOnly;
  String get searchQuery => _searchQuery;
  bool get hasMore => _meta?.hasMore ?? false;
  bool get isEmpty => !_isLoading && displayedArticles.isEmpty;
  Set<int> get readArticleIds => _readArticleIds;

  bool isArticleRead(int id) => _readArticleIds.contains(id);

  // --- Dynamic Groupings & Sections ---

  /// Artikel untuk Carousel Slider di atas (3 - 5 artikel pilihan)
  List<ArticleItem> get carouselArticles {
    if (_articles.isEmpty) return [];
    return _articles.take(5).toList();
  }

  /// Artikel yang terbit pada hari ini
  List<ArticleItem> get todayArticles {
    final now = DateTime.now();
    return _articles.where((a) {
      if (a.publishedAt == null) return false;
      final d = a.publishedAt!;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  /// Artikel yang terbit pada bulan kalender berjalan
  List<ArticleItem> get thisMonthArticles {
    final now = DateTime.now();
    return _articles.where((a) {
      if (a.publishedAt == null) return false;
      final d = a.publishedAt!;
      return d.year == now.year && d.month == now.month;
    }).toList();
  }

  /// Artikel terpopuler (Top News diurutkan berdasarkan views_count terbanyak)
  List<ArticleItem> get topArticles {
    final list = List<ArticleItem>.from(_articles);
    list.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    return list;
  }

  /// Artikel yang ditampilkan setelah menerapkan filter kategori, timeframe, unread, dan search
  List<ArticleItem> get displayedArticles {
    var result = List<ArticleItem>.from(_articles);

    // Filter Unread
    if (_filterUnreadOnly) {
      result = result.where((a) => !_readArticleIds.contains(a.id)).toList();
    }

    // Filter Timeframe
    final now = DateTime.now();
    if (_selectedTimeframe == 'Hari Ini') {
      result = result.where((a) {
        if (a.publishedAt == null) return false;
        final d = a.publishedAt!;
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList();
    } else if (_selectedTimeframe == 'Bulan Ini') {
      result = result.where((a) {
        if (a.publishedAt == null) return false;
        final d = a.publishedAt!;
        return d.year == now.year && d.month == now.month;
      }).toList();
    } else if (_selectedTimeframe == '🔥 Top News') {
      result.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));
    }

    return result;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadReadArticleIds() async {
    _readArticleIds = await _repository.getReadArticleIds();
    notifyListeners();
  }

  Future<void> markAsRead(int articleId) async {
    if (_readArticleIds.contains(articleId)) return;
    _readArticleIds.add(articleId);
    notifyListeners();
    await _repository.markArticleAsRead(articleId);
  }

  Future<void> markAsUnread(int articleId) async {
    if (!_readArticleIds.contains(articleId)) return;
    _readArticleIds.remove(articleId);
    notifyListeners();
    await _repository.markArticleAsUnread(articleId);
  }

  Future<void> toggleReadStatus(int articleId) async {
    final nowRead = await _repository.toggleReadStatus(articleId);
    if (nowRead) {
      _readArticleIds.add(articleId);
    } else {
      _readArticleIds.remove(articleId);
    }
    notifyListeners();
  }

  Future<void> fetchArticles({bool isRefresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    if (!isRefresh) {
      _articles = [];
    }
    notifyListeners();

    try {
      final result = await _repository.getArticles(
        page: 1,
        perPage: 15,
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
      );

      _articles = result.articles;
      _meta = result.meta;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Gagal memuat artikel: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = (_meta?.currentPage ?? 1) + 1;
      final result = await _repository.getArticles(
        page: nextPage,
        perPage: 15,
        category: _selectedCategory == 'Semua' ? null : _selectedCategory,
        search: _searchQuery.trim().isEmpty ? null : _searchQuery.trim(),
      );

      _articles.addAll(result.articles);
      _meta = result.meta;
    } catch (_) {
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
    fetchArticles();
  }

  void setTimeframe(String timeframe) {
    if (_selectedTimeframe == timeframe) return;
    _selectedTimeframe = timeframe;
    notifyListeners();
  }

  void toggleFilterUnreadOnly() {
    _filterUnreadOnly = !_filterUnreadOnly;
    notifyListeners();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      fetchArticles();
    });
  }

  void clearSearch() {
    _searchQuery = '';
    _debounceTimer?.cancel();
    fetchArticles();
  }

  Future<ArticleItem?> fetchDetail(dynamic idOrSlug) async {
    try {
      final detail = await _repository.getArticleDetail(idOrSlug);
      // Auto mark as read on detail view
      markAsRead(detail.id);
      return detail;
    } catch (e) {
      return null;
    }
  }
}
