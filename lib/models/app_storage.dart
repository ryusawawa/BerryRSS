import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'rss_node.dart';

class BookmarkItem {
  final String title;
  final String url;
  BookmarkItem({required this.title, required this.url});

  Map<String, dynamic> toJson() => {'title': title, 'url': url};
  factory BookmarkItem.fromJson(Map<String, dynamic> json) =>
      BookmarkItem(title: json['title'] ?? '', url: json['url'] ?? '');
}

class HistoryItem {
  final String title;
  final String url;
  final DateTime timestamp;
  HistoryItem({required this.title, required this.url, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'title': title,
        'url': url,
        'timestamp': timestamp.toIso8601String(),
      };
  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        title: json['title'] ?? '',
        url: json['url'] ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      );
}

class DownloadTask {
  final String id;
  final String filename;
  final String url;
  double progress; // 0.0 ~ 1.0
  bool isCompleted;

  DownloadTask({
    required this.id,
    required this.filename,
    required this.url,
    this.progress = 0.0,
    this.isCompleted = false,
  });
}

class AppStorage {
  static const _keyCustomUrl = 'custom_url';
  static const _keySearchEngine = 'search_engine';
  static const _keyThemeMode = 'theme_mode';
  static const _keyRssTree = 'rss_tree_json';
  static const _keyHistory = 'history_json';
  static const _keyBookmarks = 'bookmarks_json';

  static Future<String> loadCustomUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomUrl) ?? '';
  }

  static Future<void> saveCustomUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomUrl, url);
  }

  static Future<String> loadSearchEngine() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySearchEngine) ?? 'https://www.google.com/search?q=';
  }

  static Future<void> saveSearchEngine(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySearchEngine, url);
  }

  static Future<String> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyThemeMode) ?? 'system';
  }

  static Future<void> saveThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode);
  }

  static Future<List<RssNode>> loadNodes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyRssTree);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => RssNode.fromJson(e)).toList();
  }

  static Future<void> saveNodes(List<RssNode> nodes) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(nodes.map((e) => e.toJson()).toList());
    await prefs.setString(_keyRssTree, raw);
  }

  static Future<List<RssNode>> loadRssTree() => loadNodes();
  static Future<void> saveRssTree(List<RssNode> nodes) => saveNodes(nodes);

  static Future<List<HistoryItem>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHistory);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => HistoryItem.fromJson(e)).toList();
  }

  static Future<void> saveHistory(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_keyHistory, raw);
  }

  static Future<List<BookmarkItem>> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyBookmarks);
    if (raw == null) return [];
    final List<dynamic> decoded = jsonDecode(raw);
    return decoded.map((e) => BookmarkItem.fromJson(e)).toList();
  }

  static Future<void> saveBookmarks(List<BookmarkItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_keyBookmarks, raw);
  }

  static Future<String> loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name') ?? 'Berry User';
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<String?> loadUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_avatar');
  }

  static Future<void> saveUserAvatar(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_avatar', path);
  }
}
