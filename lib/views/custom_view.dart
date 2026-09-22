import 'package:flutter/material.dart';
import 'browser_view.dart';

class CustomView extends StatefulWidget {
  final String customUrl;

  const CustomView({
    super.key,
    required this.customUrl,
  });

  @override
  State<CustomView> createState() => _CustomViewState();
}

class _CustomViewState extends State<CustomView> {
  @override
  Widget build(BuildContext context) {
    if (widget.customUrl.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('カスタムビュー'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'マイページでカスタムURLが設定されていません。\nマイページからお好みのURLを設定してください。',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: BrowserView(
          key: ValueKey(widget.customUrl),
          url: widget.customUrl,
          showBar: true,
        ),
      ),
    );
  }
}
