import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;
import 'src/rust/frb_generated.dart';
import 'models/rss_node.dart';
import 'views/find_view.dart';
import 'views/timeline_view.dart';
import 'views/rss_view.dart';
import 'views/my_page_view.dart';
import 'views/browser_view.dart';
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
  String _searchEngineUrl = 'https://www.startpage.com/sp/search?query=';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString('theme_mode') ?? 'system';
    setState(() {
      _searchEngineUrl = prefs.getString('search_engine_url') ?? 'https://www.startpage.com/sp/search?query=';
      if (themeStr == 'dark') _themeMode = ThemeMode.dark;
      if (themeStr == 'light') _themeMode = ThemeMode.light;
    });
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode.name);
    setState(() => _themeMode = mode);
  }

  Future<void> _setSearchEngine(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('search_engine_url', url);
    setState(() => _searchEngineUrl = url);
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
        searchEngineUrl: _searchEngineUrl,
        onThemeChanged: _setThemeMode,
        onSearchEngineChanged: _setSearchEngine,
      ),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final String searchEngineUrl;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<String> onSearchEngineChanged;

  const MainHomeScreen({
    super.key,
    required this.themeMode,
    required this.searchEngineUrl,
    required this.onThemeChanged,
    required this.onSearchEngineChanged,
  });

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  bool _isGrouped = true;
  bool _isLoadingArticles = false;
  List<ArticleItem> _fetchedArticles = [];

  List<RssNode> _rootNodes = [
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
    _loadSavedNodes();
  }

  Future<void> _loadSavedNodes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('rss_root_nodes');
    if (jsonStr != null && jsonStr.isNotEmpty) {
      setState(() {
        _rootNodes = RssNode.decodeList(jsonStr);
      });
    }
    _fetchRssArticles();
  }

  Future<void> _saveNodes() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('rss_root_nodes', RssNode.encodeList(_rootNodes));
  }

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
                content: description.replaceAll(RegExp(r'<[^>]*>'), ''),
              ));
            }
          }
        }
      } catch (e) {
        debugPrint('Fetch Error: $e');
      }
    }

    setState(() {
      _fetchedArticles = newArticles;
      _isLoadingArticles = false;
    });
  }

  void _openBrowser(String queryOrUrl) {
    String finalUrl = queryOrUrl;
    if (!queryOrUrl.startsWith('http://') && !queryOrUrl.startsWith('https://')) {
      finalUrl = '${widget.searchEngineUrl}${Uri.encodeComponent(queryOrUrl)}';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BrowserView(
          initialUrl: finalUrl,
          defaultSearchEngine: widget.searchEngineUrl,
        ),
      ),
    );
  }

  void _addNode(RssNode newNode, RssNode? parentNode) {
    setState(() {
      if (parentNode == null) {
        _rootNodes.firstWhere((n) => n.id == 'mine').children.add(newNode);
      } else {
        parentNode.children.add(newNode);
      }
    });
    _saveNodes();
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
    _saveNodes();
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
        searchEngineUrl: widget.searchEngineUrl,
        onThemeChanged: widget.onThemeChanged,
        onGroupedChanged: (val) => setState(() => _isGrouped = val),
        onSearchEngineChanged: widget.onSearchEngineChanged,
      ),
    ];

    return Scaffold(
      appBar: AppToolbar(
        title: titles[_currentIndex],
        onSearchSubmitted: _openBrowser,
      ),
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
