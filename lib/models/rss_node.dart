import 'dart:convert';

class RssNode {
  final String id;
  String name;
  final bool isFolder;
  String? url;
  final List<RssNode> children;

  RssNode({
    required this.id,
    required this.name,
    required this.isFolder,
    this.url,
    List<RssNode>? children,
  }) : children = children ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'isFolder': isFolder,
        'url': url,
        'children': children.map((c) => c.toJson()).toList(),
      };

  factory RssNode.fromJson(Map<String, dynamic> json) {
    return RssNode(
      id: json['id'] as String,
      name: json['name'] as String,
      isFolder: json['isFolder'] as bool,
      url: json['url'] as String?,
      children: (json['children'] as List<dynamic>?)
              ?.map((c) => RssNode.fromJson(c as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static String encodeList(List<RssNode> nodes) =>
      json.encode(nodes.map((n) => n.toJson()).toList());

  static List<RssNode> decodeList(String str) {
    if (str.isEmpty) return [];
    final Iterable l = json.decode(str);
    return List<RssNode>.from(l.map((model) => RssNode.fromJson(model)));
  }
}

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
}
