import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../models/app_storage.dart';
import 'browser_view.dart';

class RssView extends StatefulWidget {
  final List<RssNode> rootNodes;
  final Function(RssNode newGroup, RssNode? parent) onAddNode;

  const RssView({
    super.key,
    required this.rootNodes,
    required this.onAddNode,
  });

  @override
  State<RssView> createState() => _RssViewState();
}

class _RssViewState extends State<RssView> {
  List<BookmarkItem> _starredArticles = [];

  @override
  void initState() {
    super.initState();
    _loadStarred();
  }

  Future<void> _loadStarred() async {
    final starred = await AppStorage.loadStarredArticles();
    if (mounted) {
      setState(() {
        _starredArticles = starred;
      });
    }
  }

  void _showAddDialog([RssNode? parentGroup]) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    bool isFolder = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(parentGroup == null ? 'ノードの追加' : '${parentGroup.name} に追加'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text('フォルダとして追加'),
                      Checkbox(
                        value: isFolder,
                        onChanged: (val) {
                          setDialogState(() {
                            isFolder = val ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'タイトル'),
                  ),
                  if (!isFolder)
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(labelText: 'RSS URL'),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('キャンセル'),
                ),
                TextButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final url = urlController.text.trim();
                    if (title.isNotEmpty) {
                      final newNode = RssNode(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: title,
                        url: isFolder ? null : url,
                        isFolder: isFolder,
                      );
                      widget.onAddNode(newNode, parentGroup);
                      Navigator.pop(ctx);
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

  void _removeNode(RssNode target, List<RssNode> list) {
    setState(() {
      list.removeWhere((node) => node.id == target.id);
    });
    AppStorage.saveNodes(widget.rootNodes);
  }

  Widget _buildNodeTree(List<RssNode> nodes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: nodes.length,
      itemBuilder: (context, index) {
        final node = nodes[index];
        return Dismissible(
          key: Key(node.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            _removeNode(node, nodes);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${node.name} を削除しました')),
            );
          },
          child: node.isFolder
              ? ExpansionTile(
                  leading: const Icon(Icons.folder),
                  title: Text(node.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _showAddDialog(node),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: _buildNodeTree(node.children),
                    ),
                  ],
                )
              : ListTile(
                  leading: const Icon(Icons.rss_feed),
                  title: Text(node.name),
                  subtitle: Text(node.url ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSS / 登録リスト'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(null),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          if (_starredArticles.isNotEmpty) ...[
            ExpansionTile(
              leading: const Icon(Icons.star, color: Colors.amber),
              title: Text('お気に入り記事 (${_starredArticles.length})'),
              children: _starredArticles.map((item) {
                return ListTile(
                  title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(item.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: Text(item.title)),
                          body: BrowserView(url: item.url, showBar: false),
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const Divider(),
          ],
          widget.rootNodes.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(
                    child: Text('RSSフォルダやフィードが登録されていません。\n右上の「+」ボタンから追加できます。', textAlign: TextAlign.center),
                  ),
                )
              : _buildNodeTree(widget.rootNodes),
        ],
      ),
    );
  }
}
