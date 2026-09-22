import 'dart:ui';
import 'package:flutter/material.dart';

class LiquidGrassToolbar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onAddRssPressed;
  final VoidCallback onFolderMenuPressed;
  final Function(String) onSearchSubmitted;

  const LiquidGrassToolbar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onAddRssPressed,
    required this.onFolderMenuPressed,
    required this.onSearchSubmitted,
  });

  @override
  State<LiquidGrassToolbar> createState() => _LiquidGrassToolbarState();
}

class _LiquidGrassToolbarState extends State<LiquidGrassToolbar> {
  bool _isSearchMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _enterSearchMode() {
    setState(() {
      _isSearchMode = true;
    });
    widget.onTabSelected(1); // Searchタブ
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: ClipRect(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // --- 通常モード（アイコン並列表示） ---
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
                            // 1. フォルダ / RSSグループボタン
                            IconButton(
                              icon: const Icon(Icons.folder_copy_outlined),
                              selectedIcon: const Icon(Icons.folder_copy),
                              isSelected: widget.currentIndex == 0,
                              onPressed: () {
                                widget.onFolderMenuPressed();
                                widget.onTabSelected(0);
                              },
                            ),
                            // 2. RSS追加ボタン
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 28),
                              color: Theme.of(context).colorScheme.primary,
                              onPressed: widget.onAddRssPressed,
                            ),
                            // 3. Searchボタン（アニメーション変形トリガー）
                            IconButton(
                              icon: const Icon(Icons.search),
                              isSelected: widget.currentIndex == 1,
                              onPressed: _enterSearchMode,
                            ),
                            // 4. タイムラインボタン
                            IconButton(
                              icon: const Icon(Icons.timeline_outlined),
                              selectedIcon: const Icon(Icons.timeline),
                              isSelected: widget.currentIndex == 2,
                              onPressed: () => widget.onTabSelected(2),
                            ),
                            // 5. Myページボタン
                            IconButton(
                              icon: const Icon(Icons.person_outline),
                              selectedIcon: const Icon(Icons.person),
                              isSelected: widget.currentIndex == 3,
                              onPressed: () => widget.onTabSelected(3),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // --- Search専用変形モード（検索バー＋左箱ボタン） ---
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOutCubic,
                      offset: _isSearchMode ? Offset.zero : const Offset(0, -1.5),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _isSearchMode ? 1.0 : 0.0,
                        child: Row(
                          children: [
                            // 左側の箱（メニュー/復元）ボタン
                            IconButton(
                              icon: const Icon(Icons.grid_view_rounded),
                              tooltip: 'メニューへ戻る',
                              onPressed: () => _exitSearchMode(0),
                            ),
                            const SizedBox(width: 4),
                            // 検索テキスト入力フィールド
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
                                  hintText: 'キーワード / URLを入力...',
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
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                if (_searchController.text.trim().isNotEmpty) {
                                  widget.onSearchSubmitted(_searchController.text.trim());
                                }
                              },
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
