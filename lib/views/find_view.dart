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
  late String _activeUrl;

  @override
  void initState() {
    super.initState();
    _activeUrl = widget.currentQuery.isNotEmpty ? widget.currentQuery : 'https://www.google.com';
  }

  @override
  void didUpdateWidget(covariant FindView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentQuery.isNotEmpty && widget.currentQuery != oldWidget.currentQuery) {
      setState(() {
        _activeUrl = widget.currentQuery;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BrowserView(
          key: ValueKey(_activeUrl),
          url: _activeUrl,
          showBar: true,
        ),
      ),
    );
  }
}
