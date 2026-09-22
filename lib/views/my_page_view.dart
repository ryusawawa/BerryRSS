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
  String _userName = 'Berry User';
  String? _avatarPath;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.customUrl);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await AppStorage.loadUserName();
    final avatar = await AppStorage.loadUserAvatar();
    if (mounted) {
      setState(() {
        _userName = name;
        _avatarPath = avatar;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      await AppStorage.saveUserAvatar(picked.path);
      if (mounted) {
        setState(() {
          _avatarPath = picked.path;
        });
      }
    }
  }

  void _editUserName() {
    final controller = TextEditingController(text: _userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ユーザー名の変更'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '新しい名前...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await AppStorage.saveUserName(newName);
                if (mounted) {
                  setState(() => _userName = newName);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
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
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage: _avatarPath != null && File(_avatarPath!).existsSync()
                            ? FileImage(File(_avatarPath!)) as ImageProvider
                            : null,
                        child: _avatarPath == null
                            ? const Icon(Icons.person, size: 44)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _userName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: _editUserName,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            title: const Text('カスタムフィールドのURL設定'),
            subtitle: Text(widget.customUrl),
            trailing: const Icon(Icons.edit),
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
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('キャンセル'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final url = _urlController.text.trim();
                        if (url.isNotEmpty) {
                          await AppStorage.saveCustomUrl(url);
                          widget.onCustomUrlChanged(url);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text('保存'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'BerryRSS v1.0.0 ©Berry',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
