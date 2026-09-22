import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'src/rust/frb_generated.dart';
import 'models/rss_node.dart';
import 'views/find_view.dart';
import 'views/timeline_view.dart';
import 'views/rss_view.dart';
import 'views/my_page_view.dart';
import 'widgets/liquid_grass_dock.dart';
import 'toolbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const CleanReaderApp());
}

class CleanReaderApp extends StatefulWidget {
  const CleanReaderApp({super.key});

  @override
  State<CleanReaderApp> createState() => _CleanReaderAppState();
}

class _CleanReaderAppState extends State<CleanReaderApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BerryRSS',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: MainHomeScreen(
        themeMode: _themeMode,
        onThemeChanged: _setThemeMode,
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MainHomeScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  bool _isGrouped = true;
  bool _isLoadingArticles = false;
  List<ArticleItem> _fetchedArticles = [];

  // ルートフォルダ構成
  final List<RssNode> _rootNodes = [
    RssNode(
      id: 'mine',
      name: 'Mine',
      isFolder: true,
      children: [],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchRssArticles();
  }

  // ノード配下のすべてのRSS URLを再帰的に収集
  List<String> _extractAllUrls(List<RssNode> nodes) {
    List<String> urls = [];
    for (var node in nodes) {
      if (!node.isFolder && node.url != null && node.url!.isNotEmpty) {
        urls.add(node.url!);
      } else if (node.isFolder) {
        urls.addAll(_extractAllUrls(node.children));
      }
    }
    return urls;
  }

  // 実際のRSSフィードを受信して解析する処理
  Future<void> _fetchRssArticles() async {
    final urls = _extractAllUrls(_rootNodes);
    if (urls.isEmpty) {
      setState(() {
        _fetchedArticles = [];
        _isLoadingArticles = false;
      });
      return;
    }

    setState(() => _isLoadingArticles = true);
    List<ArticleItem> newArticles = [];

    for (var urlStr in urls) {
      try {
        final response = await http.get(Uri.parse(urlStr)).timeout(const Duration(seconds: 5));
        if (response.statusCode == 200) {
          final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
          
          // RSS 2.0 / Atom 両方の簡易パース
          final items = document.findAllElements('item');
          if (items.isNotEmpty) {
            for (var item in items) {
              final title = item.findElements('title').firstOrNull?.innerText ?? '無題';
              final link = item.findElements('link').firstOrNull?.innerText ?? '';
              final pubDate = item.findElements('pubDate').firstOrNull?.innerText ?? '';
              final description = item.findElements('description').firstOrNull?.innerText ?? '';

              newArticles.add(ArticleItem(
                id: link.isNotEmpty ? link : title,
                title: title,
                link: link,
                pubDate: pubDate,
                content: description.replaceAll(RegExp(r'<[^>]*>'), ''), // タグ除去
              ));
            }
          } else {
            // Atom フィード対応
            final entries = document.findAllElements('entry');
            for (var entry in entries) {
              final title = entry.findElements('title').firstOrNull?.innerText ?? '無題';
              final linkEl = entry.findElements('link').firstOrNull;
              final link = linkEl?.getAttribute('href') ?? entry.findElements('id').firstOrNull?.innerText ?? '';
              final updated = entry.findElements('updated').firstOrNull?.innerText ?? '';
              final summary = entry.findElements('summary').firstOrNull?.innerText ?? 
                              entry.findElements('content').firstOrNull?.innerText ?? '';

              newArticles.add(ArticleItem(
                id: link.isNotEmpty ? link : title,
                title: title,
                link: link,
                pubDate: updated,
                content: summary.replaceAll(RegExp(r'<[^>]*>'), ''),
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('RSS Fetch Error ($urlStr): $e');
      }
    }

    setState(() {
      _fetchedArticles = newArticles;
      _isLoadingArticles = false;
    });
  }

  void _addNode(RssNode newNode, RssNode? parentNode) {
    setState(() {
      if (parentNode == null) {
        _rootNodes.firstWhere((n) => n.id == 'mine').children.add(newNode);
      } else {
        parentNode.children.add(newNode);
      }
    });
    _fetchRssArticles();
  }

  void _deleteNode(String id) {
    void removeRecursive(List<RssNode> list) {
      list.removeWhere((node) => node.id == id);
      for (var node in list) {
        if (node.isFolder) {
          removeRecursive(node.children);
        }
      }
    }

    setState(() {
      removeRecursive(_rootNodes);
    });
    _fetchRssArticles();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Find', 'Timeline', 'RSS Directory', 'My Page'];

    final views = [
      FindView(
        rootNodes: _rootNodes,
        onAddNode: _addNode,
        onDeleteNode: _deleteNode,
      ),
      TimelineView(
        articles: _fetchedArticles,
        isLoading: _isLoadingArticles,
        onRefresh: _fetchRssArticles,
      ),
      RssView(
        rootNodes: _rootNodes,
        isGrouped: _isGrouped,
      ),
      MyPageView(
        themeMode: widget.themeMode,
        isGrouped: _isGrouped,
        onThemeChanged: widget.onThemeChanged,
        onGroupedChanged: (val) => setState(() => _isGrouped = val),
      ),
    ];

    return Scaffold(
      appBar: AppToolbar(title: titles[_currentIndex]),
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: LiquidGrassDock(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
