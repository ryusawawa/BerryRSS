import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';

class BrowserView extends StatefulWidget {
  final String url;
  final bool isIncognito;

  const BrowserView({
    super.key,
    required this.url,
    this.isIncognito = false,
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  late final WebViewController _controller;
  String _currentUrl = '';
  String _pageTitle = '';
  int _loadingProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  String _selectedEngine = 'Startpage';

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
            final canBack = await _controller.canGoBack();
            final canForward = await _controller.canGoForward();
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _pageTitle = title;
                _canGoBack = canBack;
                _canGoForward = canForward;
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
    if (oldWidget.url != widget.url) {
      _controller.loadRequest(Uri.parse(widget.url));
    }
  }

  String _getDomain(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.isEmpty ? url : uri.host;
    } catch (_) {
      return url;
    }
  }

  void _showSearchEngineDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('デフォルト検索エンジンの選択'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Startpage (プライバシー重視)'),
              leading: Radio<String>(
                value: 'Startpage',
                groupValue: _selectedEngine,
                onChanged: (val) {
                  setState(() => _selectedEngine = val!);
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              title: const Text('Google'),
              leading: Radio<String>(
                value: 'Google',
                groupValue: _selectedEngine,
                onChanged: (val) {
                  setState(() => _selectedEngine = val!);
                  Navigator.pop(ctx);
                },
              ),
            ),
            ListTile(
              title: const Text('DuckDuckGo'),
              leading: Radio<String>(
                value: 'DuckDuckGo',
                groupValue: _selectedEngine,
                onChanged: (val) {
                  setState(() => _selectedEngine = val!);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isIncognito ? Colors.grey[900] : null,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.search),
              title: Text('検索エンジンの変更 ($_selectedEngine)'),
              onTap: () {
                Navigator.pop(ctx);
                _showSearchEngineDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_add_outlined),
              title: const Text('ブックマークに追加'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ブックマークに保存しました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('ページを共有'),
              onTap: () {
                Navigator.pop(ctx);
                if (_currentUrl.isNotEmpty) {
                  Share.share(_currentUrl, subject: _pageTitle);
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
            ListTile(
              leading: const Icon(Icons.add_to_home_screen),
              title: const Text('ホーム画面に追加'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ホーム画面ショートカットを作成しました')),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: isDark ? Colors.grey[950] : Colors.grey[100],
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    onPressed: _canGoBack ? () => _controller.goBack() : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios, size: 18),
                    onPressed: _canGoForward ? () => _controller.goForward() : null,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[900] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            widget.isIncognito ? Icons.privacy_tip : Icons.lock_outline,
                            size: 14,
                            color: widget.isIncognito ? Colors.purpleAccent : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _getDomain(_currentUrl),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.refresh, size: 16),
                            onPressed: () => _controller.reload(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.tab, size: 22),
                    tooltip: 'タブ一覧',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('現在 1 つのタブが開いています')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, size: 22),
                    onPressed: _showMenu,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
