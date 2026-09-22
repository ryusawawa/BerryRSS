class RssNode {
  final String id;
  String name;
  bool isFolder;
  String? url;
  List<RssNode> children;

  RssNode({
    required this.id,
    required this.name,
    this.isFolder = false,
    this.url,
    List<RssNode>? children,
  }) : children = children ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isFolder': isFolder,
        'url': url,
        'children': children.map((e) => e.toJson()).toList(),
      };

  factory RssNode.fromJson(Map<String, dynamic> json) => RssNode(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        isFolder: json['isFolder'] ?? false,
        url: json['url'],
        children: (json['children'] as List<dynamic>?)
                ?.map((e) => RssNode.fromJson(e))
                .toList() ??
            [],
      );
}

class ArticleItem {
  final String id;
  final String title;
  final String summary;
  final String url;
  final String pubDate;
  final String sourceName;
  bool isFavorite;

  ArticleItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.url,
    required this.pubDate,
    required this.sourceName,
    this.isFavorite = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'url': url,
        'pubDate': pubDate,
        'sourceName': sourceName,
        'isFavorite': isFavorite,
      };

  factory ArticleItem.fromJson(Map<String, dynamic> json) => ArticleItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        summary: json['summary'] ?? '',
        url: json['url'] ?? '',
        pubDate: json['pubDate'] ?? '',
        sourceName: json['sourceName'] ?? '',
        isFavorite: json['isFavorite'] ?? false,
      );
}
