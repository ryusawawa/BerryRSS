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
      title: 'ヨミ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9BB1E2),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationScreen(),
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

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // デフォルトは真ん中の「瓶」

  int coins = 0;
  int maxLimit = 10;
  List<TsumiItem> items = [];
  Color bottleColor = const Color(0xFFD4E2F4);
  String bottleType = 'normal'; // 'normal', 'sake', 'cola'
  List<String> unlockedBottles = ['normal'];

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
      bottleType = prefs.getString('bottleType') ?? 'normal';
      unlockedBottles = prefs.getStringList('unlockedBottles') ?? ['normal'];
      final int? savedColor = prefs.getInt('bottleColor');
      if (savedColor != null) {
        bottleColor = Color(savedColor);
      }
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
    await prefs.setString('bottleType', bottleType);
    await prefs.setStringList('unlockedBottles', unlockedBottles);
    await prefs.setInt('bottleColor', bottleColor.value);
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

  // ドメイン抽出ヘルパー
  String _extractDomain(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return uri.host.toLowerCase();
    } catch (_) {
      return '';
    }
  }

  Future<void> _consumeItem(TsumiItem item) async {
    int reward = 10;
    bool isCombo = false;

    // ドメイン合体ギミックのチェック
    final domain = _extractDomain(item.url);
    if (domain.isNotEmpty) {
      final sameDomainItems = items.where((e) => e.id != item.id && _extractDomain(e.url) == domain).toList();
      if (sameDomainItems.isNotEmpty) {
        isCombo = true;
        reward = 100; // 大当たり！
        // ヒ・ミ・ツ図鑑にアンロック保存
        final prefs = await SharedPreferences.getInstance();
        List<String> secrets = prefs.getStringList('secret_yomi') ?? [];
        if (!secrets.contains(domain)) {
          secrets.add(domain);
          await prefs.setStringList('secret_yomi', secrets);
        }
        // 相方も一緒に消す（合体演出）
        final partner = sameDomainItems.first;
        setState(() {
          items.removeWhere((element) => element.id == item.id || element.id == partner.id);
          coins = (coins + reward).clamp(0, 999999);
        });
        _saveData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✨ 運命の出会い！ドメイン合体で100コイン獲得 ＆ 「ヒ・ミ・ツ」解放！')),
        );
        return;
      }
    }

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

  void _changeBottleColor(Color color) {
    setState(() {
      bottleColor = color;
    });
    _saveData();
  }

  void _showAddDialog() {
    final titleController = TextEditingController();
    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ヨミを追加'),
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
    void _buyBottle(String type) {
      if (coins >= 100) {
        setState(() {
          coins -= 100;
          unlockedBottles.add(type);
          bottleType = type;
        });
        _saveData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('🎉 新しい瓶の形を手に入れました！')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('コインが足りません（必要: 100コイン）')),
        );
      }
    }

    void _changeBottleType(String type) {
      setState(() {
        bottleType = type;
      });
      _saveData();
    }

    final List<Widget> screens = [
      CustomScreen(
        currentBottleColor: bottleColor,
        onColorChanged: _changeBottleColor,
        currentBottleType: bottleType,
        unlockedBottles: unlockedBottles,
        onBottleTypeChanged: _changeBottleType,
        onBuyBottle: _buyBottle,
        coins: coins,
      ),
      YomiListScreen(items: items),
      BottleHomeTab(
        coins: coins,
        maxLimit: maxLimit,
        items: items,
        bottleColor: bottleColor,
        bottleType: bottleType,
        onExpand: _expandLimit,
        onConsume: _consumeItem,
      ),
      RssScreen(onAddRssItem: _addItem),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ヨミ', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🪙 $coins | 📚 ${items.length}/$maxLimit',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: screens[_currentIndex],
      floatingActionButton: _currentIndex == 2
          ? FloatingActionButton(
              onPressed: _showAddDialog,
              backgroundColor: const Color(0xFFB4C6E7),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F5).withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFD4B2A7),
            width: 2.5,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Container(
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF4A6FA5),
              unselectedItemColor: Colors.grey.shade500,
              selectedFontSize: 12,
              unselectedFontSize: 11,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.build_rounded),
                  label: 'カスタム',
                ),
                BottomNavigationBarItem(
                  icon: Text('(・ω・)', style: TextStyle(fontSize: 16, height: 1.4)),
                  label: 'ヨミ一覧',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.wine_bar_rounded),
                  label: '瓶',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.forum_rounded),
                  label: 'RSS',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_rounded),
                  label: '設定',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottleHomeTab extends StatelessWidget {
  final String bottleType;
  final int coins;
  final int maxLimit;
  final List<TsumiItem> items;
  final Color bottleColor;
  final VoidCallback onExpand;
  final Function(TsumiItem) onConsume;

  const BottleHomeTab({
    super.key,
    required this.coins,
    required this.maxLimit,
    required this.items,
    required this.bottleType,
    required this.bottleColor,
    required this.onExpand,
    required this.onConsume,
  });

  @override
  Widget build(BuildContext context) {
    final pastelColors = [
      const Color(0xFFFFB3B3), const Color(0xFFFFC1C1), const Color(0xFFFFD6D6), const Color(0xFFFFEAEA),
      const Color(0xFFFFC8A2), const Color(0xFFFFD5B6), const Color(0xFFFFE3CB), const Color(0xFFFFF0E0),
      const Color(0xFFFF9BAA), const Color(0xFFA6B4), const Color(0xFFFFB3BF), const Color(0xFFFFCAD5),
      const Color(0xFFFFB6C1), const Color(0xFFFFC1CB), const Color(0xFFFFD1D7), const Color(0xFFFFE4EA),
      const Color(0xFFE5B4D6), const Color(0xFFEDC1DE), const Color(0xFFF5CEE6), const Color(0xFFFBE0EF),
      const Color(0xFFFFC4B8), const Color(0xFFFFD1C6), const Color(0xFFFFDFD5), const Color(0xFFFFEFEB),
      const Color(0xFFD3BCE8), const Color(0xFFDEC7ED), const Color(0xFFE8D3F3), const Color(0xFFF3E1F9),
      const Color(0xFFE5AAD2), const Color(0xFFEFB5DA), const Color(0xFFF8C1E2), const Color(0xFFFFCEEB),
      const Color(0xFFBEB3CB), const Color(0xFFCBC1D4), const Color(0xFFD8CEE0), const Color(0xFFE6DBEB),
      const Color(0xFFA6D8E4), const Color(0xFFB5E0EB), const Color(0xFFC5E8F2), const Color(0xFFD4F1F8),
      const Color(0xFFA5BFE8), const Color(0xFFB3C9ED), const Color(0xFFC3D4F3), const Color(0xFFD3E0F9),
      const Color(0xFFAEBFD3), const Color(0xFFB8CADF), const Color(0xFFC5D5EB), const Color(0xFFD3E0F7),
      const Color(0xFF9CC7C5), const Color(0xFFABD2D0), const Color(0xFFBCE0DF), const Color(0xFFCCECEB),
      const Color(0xFFA7DBCB), const Color(0xFFB5E4D5), const Color(0xFFC6EEDD), const Color(0xFFD7F8E6),
      const Color(0xFFB0CAC4), const Color(0xFFBCCFCE), const Color(0xFFC8D4D8), const Color(0xFFD5E0E3),
      const Color(0xFFA6E1CA), const Color(0xFFB3E6D5), const Color(0xFFC3ECD9), const Color(0xFFD3F2E6),
      const Color(0xFFCBE6B2), const Color(0xFFD5EEC4), const Color(0xFFDFF5D6), const Color(0xFFE9FCE8),
      const Color(0xFFBFCABA), const Color(0xFFCBD5C5), const Color(0xFFD8E0D1), const Color(0xFFE5EBDE),
      const Color(0xFFFFF4B3), const Color(0xFFFFF7C1), const Color(0xFFFFFAD1), const Color(0xFFFFFDDF),
      const Color(0xFFFFE7B3), const Color(0xFFFFEDC1), const Color(0xFFFFF2CF), const Color(0xFFFFF8DF),
      const Color(0xFFECE3BE), const Color(0xFFF3E9C9), const Color(0xFFF9F0D4), const Color(0xFFFFFAE0),
      const Color(0xFFFFDCB3), const Color(0xFFFFE2C4), const Color(0xFFFFE9D5), const Color(0xFFFFF0E6),
      const Color(0xFFFFC4A6), const Color(0xFFFFD1B3), const Color(0xFFFFDEC1), const Color(0xFFFFEBCE),
      const Color(0xFFE3C5A6), const Color(0xFFEBD1B8), const Color(0xFFF2DEC9), const Color(0xFFF9ECD9),
    ];

    final faces = [
      '(՞˶･֊･˶՞)', '(◍´˘`◍)', 'ꕤ•ᴗ•ಣ', '(੭ ᐕ)', '( ⁠ꈍ⁠ᴗ⁠ꈍ⁠)',
      '(⁠◍⁠•⁠ᴗ⁠•⁠◍⁠)', '( ฅ•ω•)ฅ', '(๑′ᴗ‵๑)', '(ᐢ • ˕ • ᐢ)', '˘͈ᗜ˘͈',
      '(๑>ᴗ<)', '(๑⃙⃘ˊ꒳​ˋ๑⃙⃘)', '( ᐛ )', '₍ ᐢ. ̫ .ᐢ ₎', '(๑ˊ͈ ꇴ ˋ͈)',
      '૮ ˶ᵔ ᵕ ᵔ˶ ა', '( *˙0˙*)۶', '₍ˆ ̳ᓀ⩊ᓂ ̳ˆ₎', '( *ˊᵕˋ)', '(∗ˊᵕ`∗)',
      '(^._.^)','˶ᵒ ᗜ ᵒ˶', '(๑´ㅂ`๑)', '𖤐ᵕ𖤐', '(⸝⸝ᵕᴗᵕ⸝⸝)',
      '( ͜ˊᗜˋ˶)', '˃ᗜ˂', '˶╹ꇴ╹˶', '(ෆ˙ᵕ˙ෆ)', '^ᴗ.ᴗ^︎',
      '૮ྀི˶´ᗜ`˶აꢾ𓍢ִ໋', '(⑉• •⑉)', '^ෆ ̫ෆ^', '(❁ᴗ͈ˬᴗ͈)', '( -⩊-)',
      '(⁠≧⁠▽⁠≦⁠)'
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: onExpand,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A6FA5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.upgrade),
                label: const Text('瓶を拡張 (50コイン)'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB5838D),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    child: Center(
                      child: Container(
                        width: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF8CA8D0), width: 3),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(40),
                            bottom: Radius.circular(60),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              bottleColor.withOpacity(0.8),
                              bottleColor.withOpacity(0.3),
                              bottleColor.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(37),
                            bottom: Radius.circular(57),
                          ),
                          child: Stack(
                            children: [
                              // ガラスのハイライト（光の反射表現）
                              Positioned(
                                top: 10,
                                left: 12,
                                bottom: 20,
                                child: Container(
                                  width: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              String face = faces[item.title.hashCode % faces.length];
                              Color cardColor = pastelColors[item.title.hashCode % pastelColors.length];
                              
                              if (item.isRotten) {
                                face = '( 💀 )';
                                cardColor = Colors.grey.shade400;
                              } else if (item.isRare) {
                                face = '(★ω★)';
                                cardColor = const Color(0xFFFFB7B2);
                              }

                              return GestureDetector(
                                onTap: () => onConsume(item),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 3,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        face,
                                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
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
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomScreen extends StatelessWidget {
  final Color currentBottleColor;
  final Function(Color) onColorChanged;
  final String currentBottleType;
  final List<String> unlockedBottles;
  final Function(String) onBottleTypeChanged;
  final Function(String) onBuyBottle;
  final int coins;

  const CustomScreen({
    super.key,
    required this.currentBottleColor,
    required this.onColorChanged,
    required this.currentBottleType,
    required this.unlockedBottles,
    required this.onBottleTypeChanged,
    required this.onBuyBottle,
    required this.coins,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFD4E2F4), const Color(0xFFE2F0D9), const Color(0xFFFFF2CC),
      const Color(0xFFFCE4D6), const Color(0xFFE1D5E7), const Color(0xFFFFD1DC),
    ];

    final bottleTypes = [
      {'id': 'normal', 'name': 'スタンダード瓶', 'cost': 0},
      {'id': 'sake', 'name': 'お酒の徳利瓶', 'cost': 100},
      {'id': 'cola', 'name': 'コーラ瓶', 'cost': 100},
    ];

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text('🧵 瓶のカスタム工房', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('コインを使って瓶の形や色を着せ替えよう！', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        const Text('■ 瓶の形を選ぶ（各100コイン）', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...bottleTypes.map((b) {
          final id = b['id'] as String;
          final name = b['name'] as String;
          final cost = b['cost'] as int;
          final isUnlocked = unlockedBottles.contains(id);
          final isSelected = currentBottleType == id;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF0EB) : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isSelected ? Colors.orange.shade300 : const Color(0xFFD4B2A7), width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                isUnlocked
                    ? ElevatedButton(
                        onPressed: () => onBottleTypeChanged(id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? Colors.orange.shade200 : Colors.white,
                        ),
                        child: Text(isSelected ? '使用中' : '変更する'),
                      )
                    : ElevatedButton(
                        onPressed: () => onBuyBottle(id),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC8A2)),
                        child: Text('購入 ($cost 🪙)'),
                      ),
              ],
            ),
          );
        }),
        const SizedBox(height: 24),
        const Text('■ 瓶の色を選ぶ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((color) {
            return GestureDetector(
              onTap: () => onColorChanged(color),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: currentBottleColor == color ? Colors.brown : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class YomiListScreen extends StatelessWidget {
  final List<TsumiItem> items;

  const YomiListScreen({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('これまで出会ったヨミ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('まだヨミがいません'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white.withOpacity(0.7),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          leading: const Text('(・ω・)', style: TextStyle(fontSize: 20)),
                          title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(item.url.isNotEmpty ? item.url : 'URLなし'),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class RssScreen extends StatefulWidget {
  final Function(String, String) onAddRssItem;
  const RssScreen({super.key, required this.onAddRssItem});

  @override
  State<RssScreen> createState() => _RssScreenState();
}

class _RssScreenState extends State<RssScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  // 実際の登録済みRSSフィード/記事リスト（初期は空またはカスタム追加分）
  final List<Map<String, String>> _customArticles = [];

  void _addArticleToList() {
    if (_titleController.text.isNotEmpty) {
      setState(() {
        _customArticles.add({
          'title': _titleController.text,
          'url': _urlController.text.isNotEmpty ? _urlController.text : 'https://example.com',
        });
      });
      _titleController.clear();
      _urlController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📡 RSS フィード管理',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'お気に入りの記事やRSSのURLを登録して、ワンタップで瓶に積もう！',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          // 記事を手動追加する入力フィールド
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD4B2A7), width: 1.5),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: '記事タイトル / RSS名', isDense: true),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(labelText: 'URL (例: https://banana.com/feed)', isDense: true),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _addArticleToList,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC8A2), elevation: 0),
                    child: const Text('リストに追加'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _customArticles.isEmpty
                ? const Center(child: Text('登録されたRSS記事はありません。上記から追加してください。', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _customArticles.length,
                    itemBuilder: (context, index) {
                      final article = _customArticles[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4B2A7), width: 1.5),
                        ),
                        child: ListTile(
                          title: Text(article['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Text(article['url']!, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          trailing: ElevatedButton(
                            onPressed: () {
                              widget.onAddRssItem(article['title']!, article['url']!);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('「${article['title']}」を瓶に積みました！')),
                              );
                            },
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFC8A2), elevation: 0),
                            child: const Text('積む', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: const [
        Text('設定', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('アプリのバージョン'),
          trailing: Text('1.0.0'),
        ),
      ],
    );
  }
}
