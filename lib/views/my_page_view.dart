import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/app_storage.dart';

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
  final String _userName = 'Berry User';
  String? _avatarPath;
  String _searchEngine = 'https://www.google.com/search?q=';
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.customUrl);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final engine = await AppStorage.loadSearchEngine();
    if (mounted) {
      setState(() {
        _searchEngine = engine;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: _avatarPath != null && File(_avatarPath!).existsSync()
                        ? FileImage(File(_avatarPath!)) as ImageProvider
                        : null,
                    child: _avatarPath == null ? const Icon(Icons.person, size: 40) : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(_userName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('テーマ設定'),
            subtitle: Text(
              widget.themeMode == ThemeMode.system
                  ? '端末の設定に従う'
                  : widget.themeMode == ThemeMode.dark
                      ? 'ダークモード'
                      : 'ライトモード',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('テーマを選択'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () {
                        widget.onThemeChanged(ThemeMode.system);
                        AppStorage.saveThemeMode('system');
                        Navigator.pop(ctx);
                      },
                      child: const Text('端末の設定に従う'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        widget.onThemeChanged(ThemeMode.light);
                        AppStorage.saveThemeMode('light');
                        Navigator.pop(ctx);
                      },
                      child: const Text('ライトモード'),
                    ),
                    SimpleDialogOption(
                      onPressed: () {
                        widget.onThemeChanged(ThemeMode.dark);
                        AppStorage.saveThemeMode('dark');
                        Navigator.pop(ctx);
                      },
                      child: const Text('ダークモード'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('検索エンジンの設定'),
            subtitle: Text(
              _searchEngine.contains('google')
                  ? 'Google'
                  : _searchEngine.contains('startpage')
                      ? 'Startpage'
                      : 'Bing',
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => SimpleDialog(
                  title: const Text('検索エンジンを選択'),
                  children: [
                    SimpleDialogOption(
                      onPressed: () async {
                        const url = 'https://www.google.com/search?q=';
                        await AppStorage.saveSearchEngine(url);
                        setState(() => _searchEngine = url);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Google'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async {
                        const url = 'https://www.startpage.com/sp/search?query=';
                        await AppStorage.saveSearchEngine(url);
                        setState(() => _searchEngine = url);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Startpage'),
                    ),
                    SimpleDialogOption(
                      onPressed: () async {
                        const url = 'https://www.bing.com/search?q=';
                        await AppStorage.saveSearchEngine(url);
                        setState(() => _searchEngine = url);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('Bing'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.link),
            title: const Text('カスタムフィールドのURL設定'),
            subtitle: Text(widget.customUrl.isEmpty ? '未設定（タップして設定）' : widget.customUrl),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('カスタムフィールドのURL設定'),
                  content: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(hintText: 'https://...'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
                    TextButton(
                      onPressed: () async {
                        final url = _urlController.text.trim();
                        await AppStorage.saveCustomUrl(url);
                        widget.onCustomUrlChanged(url);
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
