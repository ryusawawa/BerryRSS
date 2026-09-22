import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/liquid_grass_card.dart';

class MyPageView extends StatefulWidget {
  final ThemeMode themeMode;
  final bool isGrouped;
  final String searchEngineUrl;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onGroupedChanged;
  final ValueChanged<String> onSearchEngineChanged;

  const MyPageView({
    super.key,
    required this.themeMode,
    required this.isGrouped,
    required this.searchEngineUrl,
    required this.onThemeChanged,
    required this.onGroupedChanged,
    required this.onSearchEngineChanged,
  });

  @override
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  String _userName = 'User';
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'User';
      _avatarPath = prefs.getString('user_avatar_path');
    });
  }

  Future<void> _pickAvatarImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar_path', picked.path);
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  Future<void> _editNameDialog() async {
    final controller = TextEditingController(text: _userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ユーザー名の編集'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '名前を入力'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', newName);
      setState(() => _userName = newName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        LiquidGrassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              GestureDetector(
                onTap: _pickAvatarImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 72,
                        height: 72,
                        color: Theme.of(context).colorScheme.primaryContainer,
                        child: _avatarPath != null && File(_avatarPath!).existsSync()
                            ? Image.file(
                                File(_avatarPath!),
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.person,
                                size: 40,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 14,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: _editNameDialog,
                        ),
                      ],
                    ),
                    const Text(
                      'タップしてプロフィール写真を変更',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LiquidGrassCard(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('ダークモード'),
                value: widget.themeMode == ThemeMode.dark,
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
        const SizedBox(height: 20),
        LiquidGrassCard(
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
                      hintText: 'https://www.startpage.com/',
                      labelText: '検索URL (例: https://www.startpage.com/sp/search?query=)',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('キャンセル'),
                    ),
                    ElevatedButton(
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
      ],
    );
  }
}
