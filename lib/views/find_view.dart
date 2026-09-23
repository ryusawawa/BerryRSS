import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import 'browser_view.dart';

class FindView extends StatefulWidget {
  final List<RssNode> rootNodes;
  final String currentQuery;

  const FindView({
    super.key,
    required this.rootNodes,
    required this.currentQuery,
  });

  @override
  State<FindView> createState() => _FindViewState();
}

class _FindViewState extends State<FindView> {
  String _activeUrl = '';

  @override
  void initState() {
    super.initState();
    _activeUrl = widget.currentQuery.trim();
  }

  @override
  void didUpdateWidget(covariant FindView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentQuery.trim() != oldWidget.currentQuery.trim()) {
      setState(() {
        _activeUrl = widget.currentQuery.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_activeUrl.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F9FC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: 56,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Berry Web Search',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.4),
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '下部のツールバーから検索キーワードまたはURLを入力してください',
                style: TextStyle(
                  fontSize: 12,
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.25),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BrowserView(
          key: ValueKey(_activeUrl),
          url: _activeUrl,
          showBar: false,
        ),
      ),
    );
  }
}
