class ArticleItem {
  final String id;
  final String title;
  final String link;
  final String pubDate;
  final String content;

  ArticleItem({
    required this.id,
    required this.title,
    required this.link,
    required this.pubDate,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'link': link,
        'pubDate': pubDate,
        'content': content,
      };

  factory ArticleItem.fromJson(Map<String, dynamic> json) => ArticleItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        link: json['link'] ?? '',
        pubDate: json['pubDate'] ?? '',
        content: json['content'] ?? '',
      );
}

class RssNode {
  final String id;
  String name;
  final bool isFolder;
  String? url;
  List<RssNode> children;
  bool isSubscribed;

  RssNode({
    required this.id,
    required this.name,
    required this.isFolder,
    this.url,
    List<RssNode>? children,
    this.isSubscribed = true,
  }) : children = children ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isFolder': isFolder,
        'url': url,
        'isSubscribed': isSubscribed,
        'children': children.map((c) => c.toJson()).toList(),
      };

  factory RssNode.fromJson(Map<String, dynamic> json) => RssNode(
        id: json['id'],
        name: json['name'],
        isFolder: json['isFolder'],
        url: json['url'],
        isSubscribed: json['isSubscribed'] ?? true,
        children: (json['children'] as List?)
            ?.map((c) => RssNode.fromJson(c))
            .toList(),
      );
}
