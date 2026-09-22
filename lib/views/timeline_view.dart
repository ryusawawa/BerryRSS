import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../models/app_storage.dart';
import '../widgets/liquid_grass_card.dart';
import 'browser_view.dart';

class TimelineView extends StatefulWidget {
  final List<ArticleItem> articles;
  final bool isLoading;
  final VoidCallback onRefresh;

  const TimelineView({
    super.key,
    required this.articles,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final Set<String> _starredUrls = {};

  @override
  void initState() {
    super.initState();
    _loadStarred();
  }

  Future<void> _loadStarred() async {
    final starred = await AppStorage.loadStarredArticles();
    if (mounted) {
      setState(() {
        _starredUrls.clear();
        _starredUrls.addAll(starred.map((e) => e.url));
      });
    }
  }

  Future<void> _toggleStar(ArticleItem item) async {
    final starred = await AppStorage.loadStarredArticles();
    if (_starredUrls.contains(item.url)) {
      starred.removeWhere((e) => e.url == item.url);
      _starredUrls.remove(item.url);
    } else {
      starred.add(BookmarkItem(title: item.title, url: item.url));
      _starredUrls.add(item.url);
    }
    await AppStorage.saveStarredArticles(starred);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSS Timeline'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.onRefresh,
          ),
        ],
      ),
      body: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.articles.isEmpty
              ? const Center(
                  child: Text('記事がありません。RSSを追加するか更新してください。'),
                )
              : RefreshIndicator(
                  onRefresh: () async => widget.onRefresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                    itemCount: widget.articles.length,
                    itemBuilder: (context, index) {
                      final item = widget.articles[index];
                      final isStarred = _starredUrls.contains(item.url);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: LiquidGrassCard(
                          child: InkWell(
                            onTap: () {
                              if (item.url.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      appBar: AppBar(title: Text(item.sourceName)),
                                      body: BrowserView(url: item.url, showBar: false),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.sourceName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          isStarred ? Icons.star : Icons.star_border,
                                          color: isStarred ? Colors.amber : Colors.grey,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _toggleStar(item),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (item.summary.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      item.summary,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    item.pubDate,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
