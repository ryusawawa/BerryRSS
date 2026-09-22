import 'package:flutter/material.dart';
import 'src/rust/frb_generated.dart';
import 'views/browser_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // RustLib の初期化エラーでアプリ全体がクラッシュ・停止するのを防止
  try {
    await RustLib.init();
  } catch (e) {
    debugPrint('RustLib init failed (Fallback to Dart mode): $e');
  }

  runApp(const BerryRSSApp());
}

class BerryRSSApp extends StatelessWidget {
  const BerryRSSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BerryRSS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const BrowserView(
        initialUrl: 'https://www.startpage.com/',
        defaultSearchEngine: 'https://www.startpage.com/',
      ),
    );
  }
}
