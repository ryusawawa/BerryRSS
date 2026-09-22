import 'package:flutter/material.dart';
import '../models/rss_node.dart';

class RssTreeView extends StatefulWidget {
  final List<RssNode> nodes;
  final String title;
  final Function(List<RssNode>) onChanged;
  final Function(String url) onSelectRssUrl;

  const RssTreeView({
    super.key,
    required this.nodes,
    this.title = 'RSSフォルダ',
    required this.onChanged,
    required this.onSelectRssUrl,
  });

  @override
  State<RssTreeView> createState() => _RssTreeViewState();
}

class _RssTreeViewState extends State<RssTreeView> {
  void _addFolder() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('フォルダの追加'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'フォルダ名...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  widget.nodes.add(RssNode(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    isFolder: true,
                  ));
                });
                widget.onChanged(widget.nodes);
              }
              Navigator.pop(ctx);
            },
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }

  void _addRssItem() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RSSの追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'サイト/フィード名...'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(hintText: 'https://... (RSS/ATOM URL)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          TextButton(
            onPressed: () {
              final name = titleController.text.trim();
              final url = urlController.text.trim();
              if (name.isNotEmpty && url.isNotEmpty) {
                setState(() {
                  widget.nodes.add(RssNode(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: name,
                    isFolder: false,
                    url: url,
                  ));
                });
                widget.onChanged(widget.nodes);
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
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.create_new_folder),
            tooltip: 'フォルダ追加',
            onPressed: _addFolder,
          ),
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: 'RSS追加',
            onPressed: _addRssItem,
          ),
        ],
      ),
      body: widget.nodes.isEmpty
          ? const Center(
              child: Text('＋ボタンからフォルダやRSSを追加してください。'),
            )
          : ListView.builder(
              itemCount: widget.nodes.length,
              itemBuilder: (context, index) {
                final node = widget.nodes[index];
                return Dismissible(
                  key: Key(node.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    setState(() {
                      widget.nodes.removeAt(index);
                    });
                    widget.onChanged(widget.nodes);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${node.name} を削除しました')),
                    );
                  },
                  child: ListTile(
                    leading: Icon(
                      node.isFolder ? Icons.folder : Icons.rss_feed,
                      color: node.isFolder ? Colors.amber : Colors.orange,
                    ),
                    title: Text(node.name),
                    subtitle: node.isFolder
                        ? Text('${node.children.length} 件のアイテム')
                        : Text(node.url ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (node.isFolder) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RssTreeView(
                              nodes: node.children,
                              title: node.name,
                              onChanged: (_) => widget.onChanged(widget.nodes),
                              onSelectRssUrl: widget.onSelectRssUrl,
                            ),
                          ),
                        );
                      } else if (node.url != null) {
                        widget.onSelectRssUrl(node.url!);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
