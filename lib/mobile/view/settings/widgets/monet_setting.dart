import 'package:chatwhiz/import.dart';
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
      title: Text(FlutterI18n.translate(context, "monet_color")),
      subtitle: Text(
        FlutterI18n.translate(context, "effective_after_reboot"),
        style: const TextStyle(
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
