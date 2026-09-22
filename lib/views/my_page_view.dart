import 'package:flutter/material.dart';
import '../widgets/liquid_grass_card.dart';

class MyPageView extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final bool isGrouped;
  final ValueChanged<bool> onGroupedChanged;
  final String searchEngineUrl;
  final ValueChanged<String> onSearchEngineChanged;

  const MyPageView({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.isGrouped,
    required this.onGroupedChanged,
    required this.searchEngineUrl,
    required this.onSearchEngineChanged,
  });

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 12),
          LiquidGrassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 36,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Berry ユーザー',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'BerryRSS v1.0.0',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LiquidGrassCard(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('ダークモード'),
                    value: isDark,
                    onChanged: (val) {
                      widget.onThemeChanged(val ? ThemeMode.dark : ThemeMode.light);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('RSSディレクトリをグループ表示'),
                    value: widget.isGrouped,
                    onChanged: widget.onGroupedChanged,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LiquidGrassCard(
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('デフォルト検索エンジン'),
                subtitle: Text(widget.searchEngineUrl),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final controller = TextEditingController(text: widget.searchEngineUrl);
                  final newEngine = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('検索エンジンの設定'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: 'https://...',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                          child: const Text('保存'),
                        ),
                      ],
                    ),
                  );
                  if (newEngine != null && newEngine.isNotEmpty) {
                    widget.onSearchEngineChanged(newEngine);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
