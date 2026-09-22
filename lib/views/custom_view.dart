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
    return Scaffold(
      body: SafeArea(
        child: BrowserView(url: customUrl),
      ),
    );
  }
}
