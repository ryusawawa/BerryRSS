class RssNode {
  final String id;
  String name;
  final bool isFolder;
  String? url; // isFolder = false の場合のみ持つ
  List<RssNode> children; // isFolder = true の場合の子要素（マトリョーシカ）
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
