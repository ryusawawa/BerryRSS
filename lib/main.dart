import 'package:flutter/material.dart';
import 'src/rust/frb_generated.dart';
import 'views/rss_view.dart';
import 'views/find_view.dart';
import 'views/timeline_view.dart';
import 'views/my_page_view.dart';
import 'models/rss_node.dart';
import 'toolbar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await RustLib.init();
  } catch (e) {
    debugPrint('RustLib init failed (Fallback to Dart mode): $e');
  }

  runApp(const BerryRSSApp());
}

class BerryRSSApp extends StatelessWidget {
  const BerryRSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BerryRSS',
      debugShowCheckedModeBanner: false,
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
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final List<RssNode> _rootNodes = [];
  final List<ArticleItem> _articles = [];
  ThemeMode _themeMode = ThemeMode.system;
  bool _isGrouped = false;
  bool _isLoading = false;
  String _searchEngineUrl = 'https://www.startpage.com/';

  final List<String> _titles = const [
    'BBS / RSS',
    'Search',
    'Timeline',
    'マイページ',
  ];

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  void _onGroupedChanged(bool value) {
    setState(() {
      _isGrouped = value;
    });
  }

  void _onSearchEngineChanged(String url) {
    setState(() {
      _searchEngineUrl = url;
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
  }

  void _onDeleteNode(String id) {
    setState(() {
      _rootNodes.removeWhere((node) => node.id == id);
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      RssView(
        rootNodes: _rootNodes,
        isGrouped: _isGrouped,
      ),
      FindView(
        rootNodes: _rootNodes,
        onAddNode: _onAddNode,
        onDeleteNode: _onDeleteNode,
      ),
      TimelineView(
        articles: _articles,
        isLoading: _isLoading,
        onRefresh: _onRefresh,
      ),
      MyPageView(
        themeMode: _themeMode,
        onThemeChanged: _onThemeChanged,
        isGrouped: _isGrouped,
        onGroupedChanged: _onGroupedChanged,
        searchEngineUrl: _searchEngineUrl,
        onSearchEngineChanged: _onSearchEngineChanged,
      ),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppToolbar(
          title: _titles[_currentIndex],
          isSearchMode: _currentIndex == 1, // Searchタブ（インデックス1）の時に変形アニメーションを起動
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.forum_outlined),
            selectedIcon: Icon(Icons.forum),
            label: 'BBS / RSS',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'マイページ',
          ),
        ],
      ),
    );
  }
}
