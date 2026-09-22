import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../widgets/liquid_grass_card.dart';

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
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                parentNode == null ? '新規作成' : '${parentNode.name} 内に追加',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment(value: false, label: Text('フィード'), icon: Icon(Icons.rss_feed)),
                        ButtonSegment(value: true, label: Text('フォルダ'), icon: Icon(Icons.folder)),
                      ],
                      selected: {isFolder},
                      onSelectionChanged: (val) {
                        setDialogState(() => isFolder = val.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '名称',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    if (!isFolder) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: urlController,
                        decoration: const InputDecoration(
                          labelText: 'RSS URL',
                          border: OutlineInputBorder(),
                          hintText: 'https://example.com/rss',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isNotEmpty) {
                      final newNode = RssNode(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        isFolder: isFolder,
                        url: isFolder ? null : urlController.text.trim(),
                      );
                      widget.onAddNode(newNode, parentNode);
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('追加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNodeTile(RssNode node, [RssNode? parent]) {
    if (node.isFolder) {
      return LiquidGrassCard(
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: ExpansionTile(
          shape: const Border(),
          leading: const Icon(Icons.folder_special, color: Colors.amber),
          title: Text(node.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.blueAccent),
                onPressed: () => _showAddDialog(node),
                tooltip: 'フォルダ内に追加',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => widget.onDeleteNode(node.id),
                tooltip: '削除',
              ),
            ],
          ),
          children: node.children.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('アイテムがありません。＋ボタンで追加してください。',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                  )
                ]
              : node.children.map((child) => _buildNodeTile(child, node)).toList(),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 4.0, bottom: 4.0),
        child: LiquidGrassCard(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              const Icon(Icons.rss_feed, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(node.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (node.url != null && node.url!.isNotEmpty)
                      Text(
                        node.url!,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                onPressed: () => widget.onDeleteNode(node.id),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('チャンネル・フォルダ管理', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              ? const Center(child: Text('右上ボタンからフォルダやRSSを追加してください'))
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  children: widget.rootNodes.map((node) => _buildNodeTile(node)).toList(),
                ),
        ),
      ],
    );
  }
}
