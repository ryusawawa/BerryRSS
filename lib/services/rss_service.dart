import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/rss_node.dart';

class RssService {
  static Future<List<ArticleItem>> fetchArticles(List<RssNode> nodes) async {
    final List<ArticleItem> articles = [];
    final urls = _collectUrls(nodes);

    for (final url in urls) {
      try {
        final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final document = xml.XmlDocument.parse(res.body);
          final items = document.findAllElements('item');
          if (items.isNotEmpty) {
            for (final item in items) {
              final title = item.findElements('title').firstOrNull?.innerText ?? '無題';
              final link = item.findElements('link').firstOrNull?.innerText ?? '';
              final pubDate = item.findElements('pubDate').firstOrNull?.innerText ?? '';
              final desc = item.findElements('description').firstOrNull?.innerText ?? '';
              articles.add(ArticleItem(
                id: link.isNotEmpty ? link : DateTime.now().microsecondsSinceEpoch.toString(),
                title: title,
                summary: desc.replaceAll(RegExp(r'<[^>]*>'), ''),
                url: link,
                publishedAt: pubDate,
                sourceName: Uri.parse(url).host,
              ));
            }
          } else {
            final entries = document.findAllElements('entry');
            for (final entry in entries) {
              final title = entry.findElements('title').firstOrNull?.innerText ?? '無題';
              final linkAttr = entry.findElements('link').firstOrNull?.getAttribute('href') ?? '';
              final updated = entry.findElements('updated').firstOrNull?.innerText ?? '';
              final summary = entry.findElements('summary').firstOrNull?.innerText ?? '';
              articles.add(ArticleItem(
                id: linkAttr.isNotEmpty ? linkAttr : DateTime.now().microsecondsSinceEpoch.toString(),
                title: title,
                summary: summary.replaceAll(RegExp(r'<[^>]*>'), ''),
                url: linkAttr,
                publishedAt: updated,
                sourceName: Uri.parse(url).host,
              ));
            }
          }
        }
      } catch (_) {}
    }
    return articles;
  }

  static List<String> _collectUrls(List<RssNode> nodes) {
    final List<String> urls = [];
    for (final node in nodes) {
      if (!node.isFolder && node.url != null && node.url!.isNotEmpty) {
        urls.add(node.url!);
      }
      if (node.children.isNotEmpty) {
        urls.addAll(_collectUrls(node.children));
      }
    }
    return urls;
  }
}
