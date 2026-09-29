import 'package:shared_preferences/shared_preferences.dart';

class ArticleLocalDataSource {
  static const String _readKey = 'sleman_read_article_ids';

  Future<Set<int>> getReadArticleIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_readKey) ?? [];
      return list.map(int.tryParse).whereType<int>().toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> markArticleAsRead(int articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = (prefs.getStringList(_readKey) ?? []).toSet();
      current.add(articleId.toString());
      await prefs.setStringList(_readKey, current.toList());
    } catch (_) {}
  }

  Future<void> markArticleAsUnread(int articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = (prefs.getStringList(_readKey) ?? []).toSet();
      current.remove(articleId.toString());
      await prefs.setStringList(_readKey, current.toList());
    } catch (_) {}
  }

  Future<bool> toggleReadStatus(int articleId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final current = (prefs.getStringList(_readKey) ?? []).toSet();
      final isCurrentlyRead = current.contains(articleId.toString());

      if (isCurrentlyRead) {
        current.remove(articleId.toString());
      } else {
        current.add(articleId.toString());
      }
      await prefs.setStringList(_readKey, current.toList());
      return !isCurrentlyRead;
    } catch (_) {
      return false;
    }
  }
}
