import 'package:flutter/material.dart';
import '../models/rss_node.dart';

class FindView extends StatefulWidget {
  final List<RssNode> rootNodes;
  final Function(RssNode newNode, RssNode? parentNode) onAddNode;
  final Function(String id) onDeleteNode;

  const FindView({
    super.key,
    required this.rootNodes,
    required this.onAddNode,
    required this.onDeleteNode,
  });

  @override
  State<FindView> createState() => _FindViewState();
}

class _FindViewState extends State<FindView> {
  void _showAddDialog([RssNode? parentNode]) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();
    bool isFolder = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(parentNode == null
              ? '新規登録（ルート）'
              : '${parentNode.name} 内に追加'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('フィード'),
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
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: '名称'),
                ),
                if (!isFolder)
                  TextField(
                    controller: urlController,
                    decoration: const InputDecoration(labelText: 'RSS URL'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final newNode = RssNode(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    isFolder: isFolder,
                    url: isFolder ? null : urlController.text,
                  );
                  widget.onAddNode(newNode, parentNode);
                  Navigator.pop(context);
                }
              },
              child: const Text('追加'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNodeTile(RssNode node, [RssNode? parent]) {
    if (node.isFolder) {
      return ExpansionTile(
        leading: const Icon(Icons.folder_special, color: Colors.amber),
        title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 20),
              onPressed: () => _showAddDialog(node),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
              onPressed: () => widget.onDeleteNode(node.id),
            ),
          ],
        ),
        children: node.children.map((child) => _buildNodeTile(child, node)).toList(),
      );
    } else {
      return ListTile(
        contentPadding: const EdgeInsets.only(left: 32.0, right: 16.0),
        leading: const Icon(Icons.rss_feed, color: Colors.orange),
        title: Text(node.name),
        subtitle: Text(node.url ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
          onPressed: () => widget.onDeleteNode(node.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('カスタムチャンネル管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: () => _showAddDialog(null),
                  icon: const Icon(Icons.add),
                  label: const Text('新規作成'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: widget.rootNodes.isEmpty
                ? const Center(child: Text('＋ボタンからジャンルやRSSを追加してください'))
                : ListView(
                    children: widget.rootNodes.map((node) => _buildNodeTile(node)).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
