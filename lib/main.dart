// lib/main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TumiYomiApp());
}

class TumiYomiApp extends StatelessWidget {
  const TumiYomiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TumiYomi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class TsumiItem {
  final String id;
  final String title;
  final String url;
  final int createdAtEpoch;
  final bool isRare;

  TsumiItem({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAtEpoch,
    required this.isRare,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'createdAtEpoch': createdAtEpoch,
        'isRare': isRare,
      };

  factory TsumiItem.fromJson(Map<String, dynamic> json) => TsumiItem(
        id: json['id'],
        title: json['title'],
        url: json['url'],
        createdAtEpoch: json['createdAtEpoch'],
        isRare: json['isRare'],
      );

  bool get isRotten {
    final nowEpoch = DateTime.now().millisecondsSinceEpoch;
    final diffDays = (nowEpoch - createdAtEpoch) / (1000 * 60 * 60 * 24);
    return diffDays >= 7;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int coins = 0;
  int maxLimit = 10;
  List<TsumiItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      coins = prefs.getInt('coins') ?? 0;
      maxLimit = prefs.getInt('maxLimit') ?? 10;
      final String? itemsStr = prefs.getString('items');
      if (itemsStr != null) {
        final List decoded = jsonDecode(itemsStr);
        items = decoded.map((e) => TsumiItem.fromJson(e)).toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', coins);
    await prefs.setInt('maxLimit', maxLimit);
    await prefs.setString(
        'items', jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  Future<void> _addItem(String title, String url) async {
    if (items.length >= maxLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('瓶がパンパンです！消化してください')),
      );
      return;
    }

    final bool isRare = (DateTime.now().millisecond % 5 == 0);

    final newItem = TsumiItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      createdAtEpoch: DateTime.now().millisecondsSinceEpoch,
      isRare: isRare,
    );

    setState(() {
      items.add(newItem);
    });
    _saveData();
  }

  Future<void> _consumeItem(TsumiItem item) async {
    int reward;
    if (item.isRotten) {
      reward = -5;
    } else {
      reward = item.isRare ? 20 : 10;
    }

    setState(() {
      items.removeWhere((element) => element.id == item.id);
      coins = (coins + reward).clamp(0, 999999);
    });
    _saveData();
  }

  void _expandLimit() {
    if (coins >= 50) {
      setState(() {
        coins -= 50;
        maxLimit += 5;
      });
      _saveData();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('コインが足りません（必要: 50コイン）')),
      );
    }
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('積読を追加'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'タイトル'),
            ),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                _addItem(titleController.text, urlController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('積む'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TumiYomi'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '🪙 $coins | 📚 ${items.length}/$maxLimit',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            color: Colors.deepPurple.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: _expandLimit,
                  icon: const Icon(Icons.upgrade),
                  label: const Text('瓶を拡張 (50コイン)'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFAEBFD3), width: 4),
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFC5D5EB),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    top: 10,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        '<(￣︶￣)>',
                        style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        String face = '(・ω・)';
                        Color cardColor = Colors.primaries[item.title.hashCode % Colors.primaries.length];

                        if (item.isRotten) {
                          face = '( 💀 )';
                          cardColor = Colors.grey.shade700;
                        } else if (item.isRare) {
                          face = '(★ω★)';
                          cardColor = Colors.amber;
                        } else if (item.title.length > 20) {
                          face = '(ﾟДﾟ;)';
                        }

                        return GestureDetector(
                          onTap: () => _consumeItem(item),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  face,
                                  style: const TextStyle(fontSize: 18, color: Colors.white),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}

