import 'package:flutter/material.dart';
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

  // マトリョーシカ構造を持つルートノードのリスト（Mineフォルダ初期保持）
  final List<RssNode> _rootNodes = [
    RssNode(
      id: 'mine',
      name: 'Mine',
      isFolder: true,
      children: [],
    ),
  ];

  void _addNode(RssNode newNode, RssNode? parentNode) {
    setState(() {
      if (parentNode == null) {
        // Mine配下にデフォルト追加
        _rootNodes.firstWhere((n) => n.id == 'mine').children.add(newNode);
      } else {
        parentNode.children.add(newNode);
      }
    });
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
      const TimelineView(),
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
