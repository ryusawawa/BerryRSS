import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/liquid_grass_card.dart';

class WebTab {
  final String id;
  String url;
  String title;
  bool isIncognito;
  WebViewController controller;

  WebTab({
    required this.id,
    required this.url,
    required this.title,
    required this.isIncognito,
    required this.controller,
  });
}

class BrowserView extends StatefulWidget {
  final String initialUrl;
  final String defaultSearchEngine;
  final Function(String url, String title)? onAddBookmark;
  final Function(String url, String title)? onAddHistory;

  const BrowserView({
    super.key,
    required this.initialUrl,
    required this.defaultSearchEngine,
    this.onAddBookmark,
    this.onAddHistory,
  });

  @override
  State<BrowserView> createState() => _BrowserViewState();
}

class _BrowserViewState extends State<BrowserView> {
  final List<WebTab> _tabs = [];
  int _activeTabIndex = 0;
  bool _isDesktopMode = false;

  @override
  void initState() {
    super.initState();
    final startUrl = _getValidUrl(
      widget.initialUrl.isNotEmpty ? widget.initialUrl : widget.defaultSearchEngine,
    );
    _createNewTab(startUrl);
  }

  String _getValidUrl(String input) {
    if (input.isEmpty) return 'https://www.google.com';
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      return 'https://$input';
    }
    return input;
  }

  WebTab _createTabObject(String url, bool isIncognito) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final validUrl = _getValidUrl(url);

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String u) {
            if (mounted) {
              setState(() {
                if (_tabs.isNotEmpty && _activeTabIndex < _tabs.length) {
                  _tabs[_activeTabIndex].url = u;
                }
              });
            }
          },
          onPageFinished: (String u) async {
            if (mounted && _tabs.isNotEmpty && _activeTabIndex < _tabs.length) {
              final activeTab = _tabs[_activeTabIndex];
              final title = await activeTab.controller.getTitle() ?? u;
              setState(() {
                activeTab.title = title;
                activeTab.url = u;
              });
              if (!activeTab.isIncognito && widget.onAddHistory != null) {
                widget.onAddHistory!(u, title);
              }
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.description}');
          },
        ),
      );

    // URL読み込みを実行
    controller.loadRequest(Uri.parse(validUrl));

    return WebTab(
      id: id,
      url: validUrl,
      title: '読み込み中...',
      isIncognito: isIncognito,
      controller: controller,
    );
  }

  void _createNewTab(String url, {bool isIncognito = false}) {
    final newTab = _createTabObject(url, isIncognito);
    setState(() {
      _tabs.add(newTab);
      _activeTabIndex = _tabs.length - 1;
    });
  }

  void _closeTab(int index) {
    if (_tabs.length <= 1) return;
    setState(() {
      _tabs.removeAt(index);
      if (_activeTabIndex >= _tabs.length) {
        _activeTabIndex = _tabs.length - 1;
      }
    });
  }

  void _toggleDesktopMode() {
    if (_tabs.isEmpty) return;
    setState(() => _isDesktopMode = !_isDesktopMode);
    final activeTab = _tabs[_activeTabIndex];
    final userAgent = _isDesktopMode
        ? 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : '';
    activeTab.controller.setUserAgent(userAgent);
    activeTab.controller.reload();
  }

  void _showTabSwitcher() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiquidGrassCard(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('タブ一覧', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pop(ctx);
                    _createNewTab(widget.defaultSearchEngine);
                  },
                ),
              ],
            ),
            const Divider(),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _tabs.length,
                itemBuilder: (c, i) {
                  final tab = _tabs[i];
                  final isSelected = i == _activeTabIndex;
                  return ListTile(
                    leading: Icon(
                      tab.isIncognito ? Icons.privacy_tip : Icons.public,
                      color: isSelected ? Colors.blueAccent : Colors.grey,
                    ),
                    title: Text(
                      tab.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(tab.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: _tabs.length > 1
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _closeTab(i);
                              Navigator.pop(ctx);
                              _showTabSwitcher();
                            },
                          )
                        : null,
                    onTap: () {
                      setState(() => _activeTabIndex = i);
                      Navigator.pop(ctx);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tabs.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeTab = _tabs[_activeTabIndex];

    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: activeTab.controller),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: '新規タブ',
                onPressed: () => _createNewTab(widget.defaultSearchEngine),
              ),
              InkWell(
                onTap: _showTabSwitcher,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).iconTheme.color ?? Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${_tabs.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 18),
                onPressed: () async {
                  if (await activeTab.controller.canGoBack()) {
                    activeTab.controller.goBack();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                onPressed: () async {
                  if (await activeTab.controller.canGoForward()) {
                    activeTab.controller.goForward();
                  }
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (value) async {
                  switch (value) {
                    case 'new_tab':
                      _createNewTab(widget.defaultSearchEngine);
                      break;
                    case 'incognito':
                      _createNewTab(widget.defaultSearchEngine, isIncognito: true);
                      break;
                    case 'bookmark':
                      if (widget.onAddBookmark != null) {
                        widget.onAddBookmark!(activeTab.url, activeTab.title);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('ブックマークに追加しました')),
                        );
                      }
                      break;
                    case 'share':
                      await Share.shareUri(Uri.parse(activeTab.url));
                      break;
                    case 'desktop':
                      _toggleDesktopMode();
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'new_tab',
                    child: Row(
                      children: [Icon(Icons.add), SizedBox(width: 12), Text('新規タブ')],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'incognito',
                    child: Row(
                      children: [Icon(Icons.privacy_tip), SizedBox(width: 12), Text('新規シークレットタブ')],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'bookmark',
                    child: Row(
                      children: [Icon(Icons.bookmark_border), SizedBox(width: 12), Text('ブックマーク')],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'share',
                    child: Row(
                      children: [Icon(Icons.share), SizedBox(width: 12), Text('共有')],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'desktop',
                    child: Row(
                      children: [Icon(Icons.desktop_windows), SizedBox(width: 12), Text('PC版サイト切り替え')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
