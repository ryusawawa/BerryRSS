import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';

class BookmarkItem {
  final String title;
  final String url;
  BookmarkItem({required this.title, required this.url});
}

class BrowserView extends StatefulWidget {
  final String url;
  final bool isIncognito;
  final bool showBar;

  const BrowserView({
    super.key,
    required this.url,
    this.isIncognito = false,
    this.showBar = true,
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  late final WebViewController _controller;
  String _currentUrl = '';
  String _pageTitle = '';
  int _loadingProgress = 0;
  static final List<BookmarkItem> _bookmarks = [];

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadingProgress = progress);
          },
          onPageStarted: (url) {
            if (mounted) setState(() => _currentUrl = url);
          },
          onPageFinished: (url) async {
            final title = await _controller.getTitle() ?? '';
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _pageTitle = title;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void didUpdateWidget(covariant BrowserView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url && widget.url.isNotEmpty) {
      _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  void showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ブックマーク一覧'),
        content: SizedBox(
          width: double.maxFinite,
          child: _bookmarks.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('ブックマークはまだありません。', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final item = _bookmarks[index];
                    return ListTile(
                      title: Text(
                        item.title.isEmpty ? item.url : item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        item.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: const Icon(Icons.bookmark),
                      onTap: () {
                        Navigator.pop(ctx);
                        _controller.loadRequest(Uri.parse(item.url));
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void showBrowserMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isIncognito ? Colors.grey[900] : null,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('ブックマークに追加'),
              onTap: () {
                Navigator.pop(ctx);
                _bookmarks.add(BookmarkItem(title: _pageTitle, url: _currentUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ブックマークに保存しました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks),
              title: const Text('ブックマーク一覧を表示'),
              onTap: () {
                Navigator.pop(ctx);
                showBookmarksDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('ページを共有'),
              onTap: () {
                Navigator.pop(ctx);
                if (_currentUrl.isNotEmpty) {
                  // ignore: deprecated_member_use
                  Share.share(_currentUrl);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('ダウンロード'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ダウンロードを開始しました')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = widget.isIncognito || theme.brightness == Brightness.dark;

    return Theme(
      data: isDark ? ThemeData.dark() : theme,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: Column(
          children: [
            if (_loadingProgress < 100)
              LinearProgressIndicator(
                value: _loadingProgress / 100.0,
                backgroundColor: Colors.transparent,
                color: theme.colorScheme.primary,
                minHeight: 2,
              ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
