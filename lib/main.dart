import 'package:flutter/material.dart';
import 'src/rust/frb_generated.dart';
import 'views/rss_view.dart';
import 'views/find_view.dart';
import 'views/timeline_view.dart';
import 'views/custom_view.dart';
import 'views/my_page_view.dart';
import 'models/rss_node.dart';
import 'models/app_storage.dart';
import 'services/rss_service.dart';
import 'widgets/liquid_grass_toolbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await RustLib.init();
  } catch (e) {
    debugPrint('RustLib init failed (Fallback to Dart mode): $e');
  }

  runApp(const BerryRSSApp());
}

class BerryRSSApp extends StatefulWidget {
  const BerryRSSApp({super.key});

  @override
  State<BerryRSSApp> createState() => _BerryRSSAppState();
}

class _BerryRSSAppState extends State<BerryRSSApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BerryRSS',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MainNavigationScreen(
        themeMode: _themeMode,
        onThemeChanged: _onThemeChanged,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  List<RssNode> _rootNodes = [];
  List<ArticleItem> _articles = [];
  bool _isLoading = false;
  String _customUrl = 'https://www.startpage.com/';
  String _searchQueryUrl = 'https://www.startpage.com/';

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final nodes = await AppStorage.loadNodes();
    final customUrl = await AppStorage.loadCustomUrl();
    setState(() {
      _rootNodes = nodes;
      _customUrl = customUrl;
    });
    _fetchRssArticles();
  }

  Future<void> _fetchRssArticles() async {
    setState(() => _isLoading = true);
    final articles = await RssService.fetchArticles(_rootNodes);
    if (mounted) {
      setState(() {
        _articles = articles;
        _isLoading = false;
      });
    }
  }

  void _onCustomUrlChanged(String url) {
    setState(() {
      _customUrl = url;
    });
  }

  void _onAddNode(RssNode node, RssNode? parent) {
    setState(() {
      if (parent != null) {
        parent.children.add(node);
      } else {
        _rootNodes.add(node);
      }
    });
    AppStorage.saveNodes(_rootNodes);
    _fetchRssArticles();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      RssView(
        rootNodes: _rootNodes,
        onAddNode: _onAddNode,
      ),
      TimelineView(
        articles: _articles,
        isLoading: _isLoading,
        onRefresh: _fetchRssArticles,
      ),
      FindView(
        rootNodes: _rootNodes,
        currentQuery: _searchQueryUrl,
      ),
      CustomView(
        customUrl: _customUrl,
      ),
      MyPageView(
        themeMode: widget.themeMode,
        onThemeChanged: widget.onThemeChanged,
        customUrl: _customUrl,
        onCustomUrlChanged: _onCustomUrlChanged,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: LiquidGrassToolbar(
        currentIndex: _currentIndex,
        onTabSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onSearchSubmitted: (query) {
          setState(() {
            if (query.startsWith('http://') || query.startsWith('https://')) {
              _searchQueryUrl = query;
            } else {
              _searchQueryUrl = 'https://www.startpage.com/sp/search?query=${Uri.encodeComponent(query)}';
            }
            _currentIndex = 2;
          });
        },
      ),
    );
  }
}
