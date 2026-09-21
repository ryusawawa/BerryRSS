import 'package:flutter/material.dart';

class MyPageView extends StatelessWidget {
  final ThemeMode themeMode;
  final bool isGrouped;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ValueChanged<bool> onGroupedChanged;

  const MyPageView({
    super.key,
    required this.themeMode,
    required this.isGrouped,
    required this.onThemeChanged,
    required this.onGroupedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text('User Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('テーマ設定'),
                  trailing: DropdownButton<ThemeMode>(
                    value: themeMode,
                    onChanged: (mode) {
                      if (mode != null) onThemeChanged(mode);
                    },
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('システムに追従')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('ライトモード')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('ダークモード')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.account_tree),
                  title: const Text('RSSタブの親ジャンルまとめ表示'),
                  value: isGrouped,
                  onChanged: onGroupedChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text('BerryRSS - Clean Reader', style: TextStyle(color: Colors.grey)),
          const Text('Version 1.0.0', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          const Text('©Berry', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }
}
