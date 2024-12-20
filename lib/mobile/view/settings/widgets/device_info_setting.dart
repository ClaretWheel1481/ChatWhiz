import 'package:flutter/material.dart';

class DeviceInfoSettings extends StatelessWidget {
  final bool selectedCollect;
  final ValueChanged<bool?> onInfoCollectChanged;

  const DeviceInfoSettings({
    super.key,
    required this.selectedCollect,
    required this.onInfoCollectChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.privacy_tip),
      title: const Text('收集设备信息'),
      subtitle: const Text(
        '仅统计设备使用情况，不收集对话信息',
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12.0,
        ),
      ),
      onTap: () {
        onInfoCollectChanged(!selectedCollect);
      },
      trailing: Checkbox(
        value: selectedCollect,
        onChanged: onInfoCollectChanged,
      ),
    );
  }
}
