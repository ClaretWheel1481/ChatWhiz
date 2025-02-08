import 'package:chatwhiz/mobile/import.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GetStorage _box = GetStorage();
  bool selectedCollect = true;
  bool selectedMonet = true;
  String _themeMode = 'system';

  @override
  void initState() {
    super.initState();
    _themeMode = _box.read('pcThemeMode') ?? 'system';
    selectedCollect = _box.read('deviceCollect') ?? true;
    selectedMonet = _box.read('monetStatus') ?? true;
  }

  void _saveThemeMode(String themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _box.write('pcThemeMode', themeMode);
    Get.changeThemeMode(
      themeMode == 'system'
          ? ThemeMode.system
          : themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,
    );
  }

  void onInfoCollect(bool? value) {
    if (value == null) return;
    setState(() {
      selectedCollect = value;
    });
    _box.write('deviceCollect', value);
  }

  void onMonet(bool? value) {
    if (value == null) return;
    setState(() {
      selectedMonet = value;
    });
    _box.write('monetStatus', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("设置"),
      ),
      body: Column(
        children: [
          ThemeSettings(
            themeMode: _themeMode,
            onThemeModeChanged: _saveThemeMode,
          ),
          MonetSettings(
            selectedMonet: selectedMonet,
            onMonetChanged: onMonet,
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text('检查更新'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return buildAboutDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
