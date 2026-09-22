import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import 'browser_view.dart';

class FindView extends StatefulWidget {
  final List<RssNode> rootNodes;
  final Function(RssNode node, RssNode? parent)? onAddNode;
  final Function(String id)? onDeleteNode;
  final String currentQuery;

  const FindView({
    super.key,
    required this.rootNodes,
    this.onAddNode,
    this.onDeleteNode,
    this.currentQuery = 'https://www.google.com',
  });

  @override
  State<FindView> createState() => _FindViewState();
}

class _FindViewState extends State<FindView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BrowserView(url: widget.currentQuery),
      ),
    );
  }
}
