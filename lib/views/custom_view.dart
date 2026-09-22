import 'package:flutter/material.dart';

class CustomView extends StatelessWidget {
  final String customUrl;

  const CustomView({
    super.key,
    required this.customUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('カスタムフィールド'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.language, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                '設定されたカスタムURL:\n$customUrl',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
