import 'package:flutter/material.dart';
import '../widgets/liquid_grass_card.dart';

class MyPageView extends StatefulWidget {
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
  State<MyPageView> createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  IconData _selectedIcon = Icons.person;

  final List<IconData> _availableIcons = [
    Icons.person,
    Icons.face,
    Icons.pets,
    Icons.star,
    Icons.bolt,
    Icons.favorite,
    Icons.smart_toy,
    Icons.rocket_launch,
  ];

  void _showIconPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('アイコンを選択'),
        content: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _availableIcons.map((icon) {
            return InkWell(
              onTap: () {
                setState(() => _selectedIcon = icon);
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(30),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: _selectedIcon == icon ? Colors.blueAccent : Colors.grey.withValues(alpha: 0.2),
                child: Icon(icon, color: _selectedIcon == icon ? Colors.white : Colors.blueAccent),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _showIconPicker,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.blueAccent,
                  child: Icon(_selectedIcon, size: 54, color: Colors.white),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.blueAccent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text('User Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          LiquidGrassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6),
                  title: const Text('テーマ設定'),
                  trailing: DropdownButton<ThemeMode>(
                    value: widget.themeMode,
                    underline: const SizedBox(),
                    onChanged: (mode) {
                      if (mode != null) widget.onThemeChanged(mode);
                    },
                    items: const [
                      DropdownMenuItem(value: ThemeMode.system, child: Text('システム')),
                      DropdownMenuItem(value: ThemeMode.light, child: Text('ライト')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text('ダーク')),
                    ],
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.account_tree),
                  title: const Text('RSSタブの親ジャンルまとめ表示'),
                  value: widget.isGrouped,
                  onChanged: widget.onGroupedChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text('BerryRSS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 4),
          const Text('Version 1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('©Berry', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
