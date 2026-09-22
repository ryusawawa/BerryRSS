import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../widgets/liquid_grass_card.dart';

class RssView extends StatefulWidget {
  final List<RssNode> rootNodes;
  final bool isGrouped;
  final Function(RssNode node, RssNode? parent)? onAddNode;

  const RssView({
    super.key,
    required this.rootNodes,
    required this.isGrouped,
    this.onAddNode,
  });

  @override
  State<RssView> createState() => _RssViewState();
}

class _RssViewState extends State<RssView> {
  void _showAddDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新規RSS/フォルダの追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '名前またはRSSのURLを入力...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty && widget.onAddNode != null) {
                final isUrl = text.startsWith('http://') || text.startsWith('https://');
                widget.onAddNode!(
                  RssNode(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: text,
                    isFolder: !isUrl,
                    url: isUrl ? text : null,
                  ),
                  null,
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('フォルダ / RSS一覧'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'フォルダ/RSSを追加',
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: widget.rootNodes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('登録されたRSSやフォルダはありません'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('RSS/フォルダを追加する'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.rootNodes.length,
              itemBuilder: (context, index) {
                final node = widget.rootNodes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: LiquidGrassCard(
                    child: Material(
                      color: Colors.transparent,
                      child: ListTile(
                        leading: Icon(
                          node.isFolder ? Icons.folder : Icons.rss_feed,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(node.name),
                        subtitle: node.url != null ? Text(node.url!) : null,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
