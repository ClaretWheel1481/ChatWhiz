import 'package:chatwhiz/mobile/import.dart';
import 'dart:io';

import 'package:flutter_i18n/flutter_i18n.dart';

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
    await FlutterI18n.refresh(context, newLocale);
    _box.write('languageCode', languageCode);
  }

  // 动态构建语言选项
  List<Widget> _buildLanguageList() {
    final languages = [
      // {'code': 'en', 'name': 'English'},
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
    showNotification("已保存，重启后生效。");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text("设置"),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              ExpansionTile(
                leading: const Icon(Icons.language),
                title: Text("语言"),
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
                title: const Text("自定义颜色"),
                subtitle: const Text(
                  "重启后生效",
                  style: TextStyle(
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
        ));
  }
}
