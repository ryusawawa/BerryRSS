import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../models/app_storage.dart';

class WebTab {
  final String id;
  String url;
  String title;
  bool isIncognito;

  WebTab({
    required this.id,
    required this.url,
    this.title = '新しいタブ',
    this.isIncognito = false,
  });
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

  static final List<WebTab> _tabs = [];
  static int _activeTabIndex = 0;
  static final List<BookmarkItem> _bookmarks = [];
  static final List<HistoryItem> _history = [];
  static final List<DownloadTask> _downloads = [];

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.url;

    if (_tabs.isEmpty) {
      _tabs.add(WebTab(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        url: widget.url,
        isIncognito: widget.isIncognito,
      ));
    }

    _initStorage();

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
              if (_tabs.isNotEmpty && _activeTabIndex < _tabs.length) {
                _tabs[_activeTabIndex].title = title.isEmpty ? url : title;
                _tabs[_activeTabIndex].url = url;
              }
              _addHistory(title, url);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _initStorage() async {
    final loadedBookmarks = await AppStorage.loadBookmarks();
    final loadedHistory = await AppStorage.loadHistory();
    if (mounted) {
      setState(() {
        _bookmarks.clear();
        _bookmarks.addAll(loadedBookmarks);
        _history.clear();
        _history.addAll(loadedHistory);
      });
    }
  }

  void _addHistory(String title, String url) {
    if (url.isEmpty || url == 'about:blank') return;
    final item = HistoryItem(
      title: title.isEmpty ? url : title,
      url: url,
      timestamp: DateTime.now(),
    );
    setState(() {
      _history.insert(0, item);
    });
    AppStorage.saveHistory(_history);
  }

  void showTabsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('タブ一覧'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final tab = _tabs[index];
                final isSelected = index == _activeTabIndex;
                return ListTile(
                  leading: Icon(
                    tab.isIncognito ? Icons.security : Icons.web,
                    color: tab.isIncognito ? Colors.purple : Colors.blue,
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
                            setModalState(() {
                              _tabs.removeAt(index);
                              if (_activeTabIndex >= _tabs.length) {
                                _activeTabIndex = _tabs.length - 1;
                              }
                            });
                          },
                        )
                      : null,
                  onTap: () {
                    setState(() {
                      _activeTabIndex = index;
                      _controller.loadRequest(Uri.parse(_tabs[index].url));
                    });
                    Navigator.pop(ctx);
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
      ),
    );
  }

  void _addNewTab({bool isIncognito = false}) {
    final newTab = WebTab(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: 'https://www.google.com',
      title: isIncognito ? 'シークレットタブ' : '新しいタブ',
      isIncognito: isIncognito,
    );
    setState(() {
      _tabs.add(newTab);
      _activeTabIndex = _tabs.length - 1;
      _controller.loadRequest(Uri.parse(newTab.url));
    });
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
                      title: Text(item.title.isEmpty ? item.url : item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      leading: const Icon(Icons.bookmark, color: Colors.amber),
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

  void showHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('閲覧履歴'),
        content: SizedBox(
          width: double.maxFinite,
          child: _history.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('履歴はありません。', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[index];
                    return ListTile(
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.url, maxLines: 1, overflow: TextOverflow.ellipsis),
                      leading: const Icon(Icons.history),
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

  void showDownloadsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ダウンロード履歴'),
        content: SizedBox(
          width: double.maxFinite,
          child: _downloads.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Text('ダウンロード履歴はありません。', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _downloads.length,
                  itemBuilder: (context, index) {
                    final task = _downloads[index];
                    return ListTile(
                      title: Text(task.filename),
                      subtitle: LinearProgressIndicator(value: task.progress),
                      trailing: Icon(
                        task.isCompleted ? Icons.check_circle : Icons.downloading,
                        color: task.isCompleted ? Colors.green : Colors.blue,
                      ),
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
      backgroundColor: widget.isIncognito ? Colors.grey[900] : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('新規タブ'),
              onTap: () {
                Navigator.pop(ctx);
                _addNewTab(isIncognito: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('新規シークレットタブ'),
              onTap: () {
                Navigator.pop(ctx);
                _addNewTab(isIncognito: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.tab),
              title: const Text('タブ一覧'),
              onTap: () {
                Navigator.pop(ctx);
                showTabsDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('履歴'),
              onTap: () {
                Navigator.pop(ctx);
                showHistoryDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('ダウンロード'),
              onTap: () {
                Navigator.pop(ctx);
                showDownloadsDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('ブックマークに追加'),
              onTap: () {
                Navigator.pop(ctx);
                final newItem = BookmarkItem(title: _pageTitle, url: _currentUrl);
                setState(() => _bookmarks.add(newItem));
                AppStorage.saveBookmarks(_bookmarks);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ブックマークに保存しました')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmarks),
              title: const Text('ブックマーク一覧'),
              onTap: () {
                Navigator.pop(ctx);
                showBookmarksDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('共有'),
              onTap: () {
                Navigator.pop(ctx);
                if (_currentUrl.isNotEmpty) {
                  // ignore: deprecated_member_use
                  Share.share(_currentUrl);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_to_home_screen),
              title: const Text('ホーム画面に追加'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ショートカットを作成しました')),
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
    final currentTab = (_tabs.isNotEmpty && _activeTabIndex < _tabs.length)
        ? _tabs[_activeTabIndex]
        : null;
    final isIncognito = widget.isIncognito || (currentTab?.isIncognito ?? false);

    final theme = Theme.of(context);
    final isDark = isIncognito || theme.brightness == Brightness.dark;

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
