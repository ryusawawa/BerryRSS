import 'package:flutter/material.dart';

const bool _useLiquidGrass = bool.fromEnvironment('ENABLE_LIQUID_GRASS');

abstract class BaseToolbar extends StatelessWidget implements PreferredSizeWidget {
  const BaseToolbar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class AppToolbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const AppToolbar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    if (_useLiquidGrass) {
      return LiquidGrassToolbar(title: title, actions: actions);
    }
    return StandardToolbar(title: title, actions: actions);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class StandardToolbar extends BaseToolbar {
  final String title;
  final List<Widget>? actions;

  const StandardToolbar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 0,
      actions: actions,
    );
  }
}

class LiquidGrassToolbar extends BaseToolbar {
  final String title;
  final List<Widget>? actions;

  const LiquidGrassToolbar({super.key, required this.title, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.03),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              Row(children: actions ?? []),
            ],
          ),
        ),
      ),
    );
  }
}
