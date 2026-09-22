import 'package:http/http.dart' as http;
import 'package:xml/xml.dart';
import '../models/rss_node.dart';

class RssService {
  static Future<List<ArticleItem>> fetchArticles(List<RssNode> nodes) async {
    final List<ArticleItem> articles = [];
    final urls = _extractUrls(nodes);

    for (final entry in urls) {
      try {
        final response = await http.get(Uri.parse(entry.value));
        if (response.statusCode == 200) {
          final document = XmlDocument.parse(response.body);
          
          // RSS 2.0 (item タグ)
          final items = document.findAllElements('item');
          if (items.isNotEmpty) {
            for (final item in items) {
              final title = item.findElements('title').firstOrNull?.innerText ?? '無題';
              final link = item.findElements('link').firstOrNull?.innerText ?? '';
              final description = item.findElements('description').firstOrNull?.innerText ?? '';
              final pubDate = item.findElements('pubDate').firstOrNull?.innerText ?? '';

              articles.add(ArticleItem(
                id: '${entry.value}_${link.isNotEmpty ? link : title}_${DateTime.now().millisecondsSinceEpoch}',
                title: title,
                summary: description,
                url: link,
                sourceName: entry.key,
                pubDate: pubDate,
              ));
            }
          } else {
            // Atom (entry タグ)
            final entries = document.findAllElements('entry');
            for (final item in entries) {
              final title = item.findElements('title').firstOrNull?.innerText ?? '無題';
              final linkAttr = item.findElements('link').firstOrNull?.getAttribute('href');
              final linkText = item.findElements('link').firstOrNull?.innerText;
              final link = linkAttr ?? linkText ?? '';
              final summary = item.findElements('summary').firstOrNull?.innerText ??
                  item.findElements('content').firstOrNull?.innerText ?? '';
              final updated = item.findElements('updated').firstOrNull?.innerText ??
                  item.findElements('published').firstOrNull?.innerText ?? '';

              articles.add(ArticleItem(
                id: '${entry.value}_${link.isNotEmpty ? link : title}_${DateTime.now().millisecondsSinceEpoch}',
                title: title,
                summary: summary,
                url: link,
                sourceName: entry.key,
                pubDate: updated,
              ));
            }
          }
        }
      } catch (e) {
        // エラー時はスキップ
      }
    }

    return articles;
  }

  static List<MapEntry<String, String>> _extractUrls(List<RssNode> nodes) {
    final List<MapEntry<String, String>> urls = [];
    for (final node in nodes) {
      if (node.isFolder) {
        urls.addAll(_extractUrls(node.children));
      } else if (node.url != null && node.url!.isNotEmpty) {
        urls.add(MapEntry(node.name, node.url!));
      }
    }
    return urls;
  }
}
