import 'dart:io';
import 'package:flutter/material.dart';

class MonetSettings extends StatelessWidget {
  final bool selectedMonet;
  final ValueChanged<bool?> onMonetChanged;

  const MonetSettings({
    super.key,
    required this.selectedMonet,
    required this.onMonetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = !Platform.isIOS;

    return ListTile(
      enabled: isEnabled,
      leading: const Icon(Icons.color_lens),
      title: const Text('Monet取色'),
      subtitle: const Text(
        '重启后生效',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12.0,
        ),
      ),
      onTap: () {
        onMonetChanged(!selectedMonet);
      },
      trailing: Checkbox(
        value: selectedMonet,
        onChanged: isEnabled ? onMonetChanged : null,
      ),
    );
  }
}
