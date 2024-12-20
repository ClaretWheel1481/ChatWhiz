import 'package:flutter/material.dart';

class ThemeSettings extends StatelessWidget {
  final String themeMode;
  final Function(String) onThemeModeChanged;

  const ThemeSettings({
    Key? key,
    required this.themeMode,
    required this.onThemeModeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.light_mode),
      title: const Text('主题设置'),
      children: [
        ListTile(
          leading: const Icon(Icons.brightness_auto),
          title: const Text('跟随系统'),
          onTap: () => onThemeModeChanged('system'),
          selected: themeMode == 'system',
        ),
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: const Text('浅色'),
          onTap: () => onThemeModeChanged('light'),
          selected: themeMode == 'light',
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('深色'),
          onTap: () => onThemeModeChanged('dark'),
          selected: themeMode == 'dark',
        ),
      ],
    );
  }
}
