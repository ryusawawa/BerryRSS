import 'package:flutter/material.dart';
import 'src/rust/frb_generated.dart';
import 'views/rss_view.dart';
import 'views/find_view.dart';
import 'views/timeline_view.dart';
import 'views/custom_view.dart';
import 'views/my_page_view.dart';
import 'models/rss_node.dart';
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
  final List<RssNode> _rootNodes = [];
  final List<ArticleItem> _articles = [];
  bool _isLoading = false;
  String _customUrl = 'https://www.startpage.com/';

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
        isGrouped: true,
      ),
      TimelineView(
        articles: _articles,
        isLoading: _isLoading,
        onRefresh: _onRefresh,
      ),
      FindView(
        rootNodes: _rootNodes,
        onAddNode: _onAddNode,
        onDeleteNode: _onDeleteNode,
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
            _currentIndex = 2; // Search画面へ移動
          });
        },
      ),
    );
  }
}
