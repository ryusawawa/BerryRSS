import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../widgets/liquid_grass_card.dart';

class RssView extends StatefulWidget {
  final List<RssNode> rootNodes;
  final Function(RssNode node, RssNode? parent)? onAddNode;

  const RssView({
    super.key,
    required this.rootNodes,
    this.onAddNode,
  });

  @override
  State<RssView> createState() => _RssViewState();
}

class _RssViewState extends State<RssView> {
  void _showAddDialog() {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    bool isFolder = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('追加'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('RSSフィード'),
                    selected: !isFolder,
                    onSelected: (selected) {
                      if (selected) setDialogState(() => isFolder = false);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('フォルダ'),
                    selected: isFolder,
                    onSelected: (selected) {
                      if (selected) setDialogState(() => isFolder = true);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: isFolder ? 'フォルダ名' : 'サイト名/タイトル',
                ),
              ),
              if (!isFolder) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: urlController,
                  decoration: const InputDecoration(
                    labelText: 'RSS/Atom URL',
                    hintText: 'https://example.com/rss.xml',
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final url = urlController.text.trim();
                if (name.isNotEmpty && widget.onAddNode != null) {
                  widget.onAddNode!(
                    RssNode(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: name,
                      isFolder: isFolder,
                      url: isFolder ? null : url,
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
            tooltip: '追加',
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: widget.rootNodes.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('右上ボタン(+)からRSSやフォルダを追加してください'),
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
                        // フォルダの場合のみ右矢印（chevron_right）を表示
                        trailing: node.isFolder ? const Icon(Icons.chevron_right) : null,
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
