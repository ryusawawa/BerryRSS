import 'package:flutter/material.dart';
import '../models/rss_node.dart';
import '../widgets/liquid_grass_card.dart';
import 'browser_view.dart';

class TimelineView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RSS Timeline'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onRefresh,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? const Center(
                  child: Text('記事がありません。RSSを追加するか更新してください。'),
                )
              : RefreshIndicator(
                  onRefresh: () async => onRefresh(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final item = articles[index];
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
                                  Text(
                                    item.sourceName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
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
