import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../widgets/liquid_grass_card.dart';

class RssView extends StatelessWidget {
  final List<RssNode> rootNodes;
  final bool isGrouped;

  const RssView({
    super.key,
    required this.rootNodes,
    required this.isGrouped,
  });

  List<RssNode> _getAllFeeds(List<RssNode> nodes) {
    List<RssNode> result = [];
    for (var node in nodes) {
      if (!node.isFolder) {
        result.add(node);
      } else {
        result.addAll(_getAllFeeds(node.children));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (rootNodes.isEmpty) {
      return const Center(
        child: Text('FindタブからジャンルやRSSを登録してください'),
      );
    }

    final displayItems = isGrouped ? rootNodes : _getAllFeeds(rootNodes);

    if (displayItems.isEmpty) {
      return const Center(child: Text('登録されているフィードがありません'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12.0),
      itemCount: displayItems.length,
      itemBuilder: (context, index) {
        final node = displayItems[index];
        return LiquidGrassCard(
          margin: const EdgeInsets.only(bottom: 10.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (node.isFolder ? Colors.amber : Colors.orange).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  node.isFolder ? Icons.folder : Icons.rss_feed,
                  color: node.isFolder ? Colors.amber : Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      node.isFolder
                          ? '${node.children.length} 件のアイテム (フォルダまとめ表示)'
                          : (node.url ?? 'URLなし'),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        );
      },
    );
  }
}
