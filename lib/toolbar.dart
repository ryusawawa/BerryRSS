import 'dart:ui';
import 'package:flutter/material.dart';

class AppToolbar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isSearchMode;
  final Function(String searchOrUrl)? onSearchSubmitted;

  const AppToolbar({
    super.key,
    required this.title,
    this.isSearchMode = false,
    this.onSearchSubmitted,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);

  @override
  State<AppToolbar> createState() => _AppToolbarState();
}

class _AppToolbarState extends State<AppToolbar> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty && widget.onSearchSubmitted != null) {
      widget.onSearchSubmitted!(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSearching = widget.isSearchMode;

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: kToolbarHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: ClipRect(
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // 通常時タイトル：左へ滑らかにスライドアウト（幅・フォント保持）
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      offset: isSearching ? const Offset(-1.2, 0) : Offset.zero,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSearching ? 0.0 : 1.0,
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // 検索入力フォーム：右からスムーズにスライドイン
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      offset: isSearching ? Offset.zero : const Offset(1.2, 0),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: isSearching ? 1.0 : 0.0,
                        child: Row(
                          children: [
                            const Icon(Icons.search, size: 20, color: Colors.grey),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                autofocus: isSearching,
                                onSubmitted: (_) => _submitSearch(),
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
