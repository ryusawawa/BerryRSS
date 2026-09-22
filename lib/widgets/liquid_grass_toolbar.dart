import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGrassToolbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final Function(String) onSearchSubmitted;
  final VoidCallback? onNewTab;
  final VoidCallback? onNewIncognitoTab;
  final VoidCallback? onShowTabs;
  final VoidCallback? onShowBookmarks;
  final VoidCallback? onShowDownloads;
  final Function(String)? onShare;
  final VoidCallback? onAddToHomeScreen;

  const LiquidGrassToolbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onSearchSubmitted,
    this.onNewTab,
    this.onNewIncognitoTab,
    this.onShowTabs,
    this.onShowBookmarks,
    this.onShowDownloads,
    this.onShare,
    this.onAddToHomeScreen,
  });

  @override
  State<LiquidGrassToolbar> createState() => _LiquidGrassToolbarState();
}

class _LiquidGrassToolbarState extends State<LiquidGrassToolbar> {
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isDesktopMode = false;
  bool _isIncognito = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _enterSearchMode() {
    setState(() {
      _isSearchMode = true;
    });
    widget.onTabSelected(2);
  }

  void _exitSearchMode([int? targetIndex]) {
    setState(() {
      _isSearchMode = false;
      _searchController.clear();
    });
    if (targetIndex != null) {
      widget.onTabSelected(targetIndex);
    }
  }

  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('閲覧履歴'),
        content: const SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Center(child: Text('履歴はありません')),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('履歴を消去しました')),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('履歴をクリア', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  void _showListDialog(String title, String emptyMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: Center(child: Text(emptyMessage)),
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

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark || _isIncognito;
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.85)
                  : Colors.white.withValues(alpha: 0.85),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  if (_isIncognito)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security, size: 16, color: Colors.purpleAccent),
                          SizedBox(width: 6),
                          Text('シークレットモード動作中', style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ListTile(
                    leading: const Icon(Icons.add_box_outlined),
                    title: const Text('新規タブ'),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _isIncognito = false);
                      if (widget.onNewTab != null) {
                        widget.onNewTab!();
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.security, color: Colors.purpleAccent),
                    title: const Text('新規シークレットタブ'),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _isIncognito = true);
                      if (widget.onNewIncognitoTab != null) {
                        widget.onNewIncognitoTab!();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('シークレットモードで新しいタブを開きました')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.tab),
                    title: const Text('タブ一覧'),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (widget.onShowTabs != null) {
                        widget.onShowTabs!();
                      } else {
                        _showListDialog('タブ一覧', '現在開いているタブは1つです');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('履歴'),
                    onTap: () {
                      Navigator.pop(ctx);
                      _showHistoryDialog();
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.download),
                    title: const Text('ダウンロード一覧'),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (widget.onShowDownloads != null) {
                        widget.onShowDownloads!();
                      } else {
                        _showListDialog('ダウンロード', 'ダウンロードしたファイルはありません');
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_outline),
                    title: const Text('ブックマーク一覧'),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (widget.onShowBookmarks != null) {
                        widget.onShowBookmarks!();
                      } else {
                        _showListDialog('ブックマーク', '登録されているブックマークはありません');
                      }
                    },
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text('共有'),
                    onTap: () {
                      Navigator.pop(ctx);
                      final currentUrl = _searchController.text.trim();
                      if (widget.onShare != null) {
                        widget.onShare!(currentUrl);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(currentUrl.isNotEmpty ? 'URLを共有: $currentUrl' : '共有対象のURLがありません')),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_to_home_screen),
                    title: const Text('ホーム画面に追加'),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (widget.onAddToHomeScreen != null) {
                        widget.onAddToHomeScreen!();
                      } else {
                        showDialog(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('ホーム画面に追加'),
                            content: const Text('ブラウザのメニューから「ホーム画面に追加」または「ショートカットを作成」を選択してください。'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c), child: const Text('OK')),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                  SwitchListTile(
                    secondary: Icon(_isDesktopMode ? Icons.desktop_windows : Icons.phone_iphone),
                    title: Text(_isDesktopMode ? 'PC版サイトを表示中' : 'モバイル版サイトを表示中'),
                    value: _isDesktopMode,
                    onChanged: (val) {
                      setState(() {
                        _isDesktopMode = val;
                      });
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || _isIncognito;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: _isIncognito
                      ? Colors.purpleAccent.withValues(alpha: 0.5)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.08)),
                  width: 1.5,
                ),
              ),
              child: ClipRect(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      offset: _isSearchMode ? const Offset(0, 1.5) : Offset.zero,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: _isSearchMode ? 0.0 : 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.folder_copy_outlined),
                              selectedIcon: const Icon(Icons.folder_copy),
                              isSelected: widget.currentIndex == 0,
                              tooltip: 'フォルダ',
                              onPressed: () => widget.onTabSelected(0),
                            ),
                            IconButton(
                              icon: const Icon(Icons.article_outlined),
                              selectedIcon: const Icon(Icons.article),
                              isSelected: widget.currentIndex == 1,
                              tooltip: 'タイムライン',
                              onPressed: () => widget.onTabSelected(1),
                            ),
                            IconButton(
                              icon: const Icon(Icons.search, size: 28),
                              isSelected: widget.currentIndex == 2,
                              tooltip: '検索',
                              onPressed: _enterSearchMode,
                            ),
                            IconButton(
                              icon: const Icon(Icons.language_outlined),
                              selectedIcon: const Icon(Icons.language),
                              isSelected: widget.currentIndex == 3,
                              tooltip: 'カスタムフィールド',
                              onPressed: () => widget.onTabSelected(3),
                            ),
                            IconButton(
                              icon: const Icon(Icons.person_outline),
                              selectedIcon: const Icon(Icons.person),
                              isSelected: widget.currentIndex == 4,
                              tooltip: 'マイページ',
                              onPressed: () => widget.onTabSelected(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      offset: _isSearchMode ? Offset.zero : const Offset(0, -1.5),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isSearchMode ? 1.0 : 0.0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              tooltip: 'メニュー',
                              onPressed: () => _showMoreMenu(context),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: _isSearchMode,
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    widget.onSearchSubmitted(val.trim());
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText: '検索キーワードまたはURLを入力...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              ),
                            IconButton(
                              icon: const Icon(Icons.grid_view_rounded),
                              tooltip: 'メニューに戻る',
                              onPressed: () => _exitSearchMode(0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
