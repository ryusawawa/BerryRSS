import 'package:flutter/material.dart';
import 'browser_view.dart';

class CustomView extends StatelessWidget {
  final String customUrl;

  const CustomView({
    super.key,
    required this.customUrl,
  });

  @override
  Widget build(BuildContext context) {
    if (customUrl.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('カスタムフィールド'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_off, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text(
                'My Pageから編集してね☆',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'URLを設定すると、ここにWebページが表示されます。',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: BrowserView(url: customUrl, showBar: false),
      ),
    );
  }
}
