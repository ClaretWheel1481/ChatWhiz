import 'package:chatwhiz/pc/import.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GetStorage _box = GetStorage();
  bool selectedCollect = true;
  bool selectedAutoCheckUpdate = true;

  @override
  void initState() {
    super.initState();
    selectedCollect = _box.read('deviceCollect') ?? true;
    selectedAutoCheckUpdate = _box.read('autoCheckUpdate') ?? true;
  }

  void onInfoCollect(bool? value) {
    if (value == null) return;
    setState(() {
      selectedCollect = value;
      _box.write('deviceCollect', value);
    });
  }

  void onAutoCheckUpdate(bool? value) {
    if (value == null) return;
    setState(() {
      selectedAutoCheckUpdate = value;
      _box.write('autoCheckUpdate', value);
    });
  }

  void showAutoCheckUpdateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('关闭自动检查更新'),
        content: const Text(
          '您需要自行前往官方仓库才能获取最新的版本情况，您确定关闭吗？',
        ),
        actions: [
          Button(
            child: const Text('是'),
            onPressed: () {
              onAutoCheckUpdate(false);
              Navigator.pop(context);
            },
          ),
          FilledButton(
            child: const Text('否'),
            onPressed: () {
              onAutoCheckUpdate(true);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
      header: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "设置",
            style: FluentTheme.of(context)
                .typography
                .title
                ?.copyWith(fontSize: 38),
          ),
        ),
      ),
      children: [
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const InfoBar(
              title: Text('提示'),
              content: Text('仅收集设备相关信息用于统计，不会收集您的对话内容。'),
              severity: InfoBarSeverity.info,
              isLong: true,
            ),
            const SizedBox(height: 10),
            Checkbox(
              content: const Text("收集设备信息"),
              checked: selectedCollect,
              onChanged: (v) {
                onInfoCollect(v);
              },
            ),
            const SizedBox(height: 10),
            Checkbox(
              content: const Text("自动检查更新"),
              checked: selectedAutoCheckUpdate,
              onChanged: (v) {
                if (v == false) {
                  showAutoCheckUpdateDialog(context);
                } else {
                  onAutoCheckUpdate(v);
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
