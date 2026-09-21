import 'package:flutter/material.dart';
import '../models/rss_node.dart';

class RssView extends StatelessWidget {
  final List<RssNode> rootNodes;
  final bool isGrouped;

  const RssView({
    super.key,
    required this.rootNodes,
    required this.isGrouped,
  });

  @override
  Widget build(BuildContext context) {
    if (rootNodes.isEmpty) {
      return const Center(child: Text('FindタブからジャンルやRSSを登録してください'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: rootNodes.length,
      itemBuilder: (context, index) {
        final node = rootNodes[index];
        return Card(
          child: ListTile(
            leading: Icon(
              node.isFolder ? Icons.folder : Icons.rss_feed,
              color: node.isFolder ? Colors.amber : Colors.orange,
            ),
            title: Text(node.name),
            subtitle: Text(
              node.isFolder
                  ? '${node.children.length} 件のアイテム (${isGrouped ? "まとめ表示" : "独立表示"})'
                  : node.url ?? '',
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}
