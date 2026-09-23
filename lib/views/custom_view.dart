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
      return const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'マイページでカスタムURLが設定されていません。\nマイページからお好みのURLを設定してください。',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.5),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BrowserView(
          key: ValueKey(widget.customUrl),
          url: widget.customUrl,
          showBar: false,
        ),
      ),
    );
  }
}
