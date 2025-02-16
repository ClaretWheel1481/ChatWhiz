import 'package:chatwhiz/mobile/import.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GetStorage _box = GetStorage();
  bool selectedMonet = true;
  String _themeMode = 'system';
  String _languageCode = 'en';
  Color pickerColor = const Color(0xff443a49);
  Color currentColor = const Color(0xff443a49);

  @override
  void initState() {
    super.initState();
    _languageCode = _box.read('languageCode') ?? 'en';
    _themeMode = _box.read('themeMode') ?? 'system';
    selectedMonet = _box.read('monetStatus') ?? true;
    currentColor = Color(_box.read('colorSeed') ?? 0xff443a49);
    Platform.isIOS
        ? selectedMonet = false
        : selectedMonet = _box.read('monetStatus') ?? true;

    Future.delayed(Duration.zero, () async {
      await FlutterI18n.refresh(context, Locale(_languageCode));
    });
  }

  // 修改语言
  void _changeLanguage(String languageCode) async {
    setState(() {
      _languageCode = languageCode;
    });
    Locale newLocale = Locale(languageCode);
    _box.write('languageCode', languageCode);
    await FlutterI18n.refresh(context, newLocale);
    setState(() {});
  }

  // 动态构建语言选项
  List<Widget> _buildLanguageList() {
    final languages = [
      {'code': 'en', 'name': 'English'},
      {'code': 'zh_CN', 'name': '中文 (简体)'},
    ];

    // 生成列表
    return languages.map((language) {
      return ListTile(
        title: Text(language['name']!),
        onTap: () => _changeLanguage(language['code']!),
        selected: _languageCode == language['code'],
      );
    }).toList();
  }

  // 保存主题
  void _saveThemeMode(String themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _box.write('themeMode', themeMode);
    Get.changeThemeMode(
      themeMode == 'system'
          ? ThemeMode.system
          : themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.dark,
    );
  }

  void onMonet(bool? value) {
    if (value == null) return;
    setState(() {
      selectedMonet = value;
    });
    _box.write('monetStatus', value);
    showNotification(FlutterI18n.translate(context, "effective_after_reboot"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(FlutterI18n.translate(context, "settings")),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                leading: const Icon(Icons.language),
                title: Text(FlutterI18n.translate(context, "language")),
                children: [
                  ..._buildLanguageList(),
                ],
              ),
              ThemeSettings(
                themeMode: _themeMode,
                onThemeModeChanged: _saveThemeMode,
              ),
              MonetSettings(
                selectedMonet: selectedMonet,
                onMonetChanged: onMonet,
              ),
              ListTile(
                enabled: !selectedMonet,
                leading: const Icon(Icons.color_lens),
                title: Text(FlutterI18n.translate(context, "custom_color")),
                subtitle: Text(
                  FlutterI18n.translate(context, "effective_after_reboot"),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12.0,
                  ),
                ),
                onTap: () {
                  showColorPickerDialog(context, currentColor, (Color color) {
                    setState(() => currentColor = color);
                    _box.write('colorSeed', currentColor.value);
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.update),
                title: Text(FlutterI18n.translate(context, "check_update")),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(FlutterI18n.translate(context, "about")),
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
        ));
  }
}
