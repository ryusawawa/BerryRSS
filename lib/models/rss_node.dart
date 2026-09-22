class RssNode {
  final String id;
  String name;
  String? url;
  final bool isFolder;
  final List<RssNode> children;

  RssNode({
    required this.id,
    required this.name,
    this.url,
    this.isFolder = false,
    List<RssNode>? children,
  }) : children = children ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'isFolder': isFolder,
        'children': children.map((c) => c.toJson()).toList(),
      };

  factory RssNode.fromJson(Map<String, dynamic> json) => RssNode(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String?,
        isFolder: json['isFolder'] as bool? ?? false,
        children: (json['children'] as List<dynamic>?)
                ?.map((c) => RssNode.fromJson(c as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class ArticleItem {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String url;
  final String publishedAt;
  final String sourceName;

  ArticleItem({
    required this.id,
    required this.title,
    required this.summary,
    this.content = '',
    required this.url,
    required this.publishedAt,
    required this.sourceName,
  });

  // timeline_view等の互換性のためのゲッター
  String get pubDate => publishedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'summary': summary,
        'content': content,
        'url': url,
        'publishedAt': publishedAt,
        'sourceName': sourceName,
      };

  factory ArticleItem.fromJson(Map<String, dynamic> json) => ArticleItem(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        summary: json['summary'] as String? ?? '',
        content: json['content'] as String? ?? '',
        url: json['url'] as String? ?? '',
        publishedAt: json['publishedAt'] as String? ?? json['pubDate'] as String? ?? '',
        sourceName: json['sourceName'] as String? ?? '',
      );
}
