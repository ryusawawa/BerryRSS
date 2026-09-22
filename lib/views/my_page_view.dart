import 'package:flutter/material.dart';
import '../widgets/liquid_grass_card.dart';

class MyPageView extends StatefulWidget {
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final String customUrl;
  final ValueChanged<String> onCustomUrlChanged;

  const MyPageView({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
    required this.customUrl,
    required this.onCustomUrlChanged,
  });

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  IconData _userIcon = Icons.person;

  final List<IconData> _iconOptions = const [
    Icons.person,
    Icons.face,
    Icons.account_circle,
    Icons.pets,
    Icons.star,
    Icons.palette,
  ];

  void _showIconPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        height: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'アイコンを選択',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _iconOptions.map((icon) {
                return IconButton(
                  icon: Icon(icon, size: 32),
                  onPressed: () {
                    setState(() {
                      _userIcon = icon;
                    });
                    Navigator.pop(ctx);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Myページ'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LiquidGrassCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _showIconPicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Icon(
                            _userIcon,
                            size: 36,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ユーザー',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '設定・アカウント管理',
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          LiquidGrassCard(
            child: Material(
              color: Colors.transparent,
              child: ListTile(
                title: const Text('カスタムフィールド (URL)'),
                subtitle: Text(widget.customUrl),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () async {
                  final controller = TextEditingController(text: widget.customUrl);
                  final newUrl = await showDialog<String>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('カスタムURLの設定'),
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
                  if (newUrl != null && newUrl.isNotEmpty) {
                    widget.onCustomUrlChanged(newUrl);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text(
              'BerryRSS v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
