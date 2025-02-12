import 'package:chatwhiz/import.dart';
import 'package:flutter/material.dart';

class ThemeSettings extends StatelessWidget {
  final String themeMode;
  final Function(String) onThemeModeChanged;

  const ThemeSettings({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.light_mode),
      title: Text(FlutterI18n.translate(context, "theme")),
      children: [
        ListTile(
          leading: const Icon(Icons.brightness_auto),
          title: Text(FlutterI18n.translate(context, "follow_system")),
          onTap: () => onThemeModeChanged('system'),
          selected: themeMode == 'system',
        ),
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: Text(FlutterI18n.translate(context, "light")),
          onTap: () => onThemeModeChanged('light'),
          selected: themeMode == 'light',
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: Text(FlutterI18n.translate(context, "dark")),
          onTap: () => onThemeModeChanged('dark'),
          selected: themeMode == 'dark',
        ),
      ],
    );
  }
}
