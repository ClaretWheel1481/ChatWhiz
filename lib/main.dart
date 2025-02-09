import 'package:chatwhiz/desktop/main.dart';
import 'package:flutter/material.dart' as md;
import 'package:get/get.dart';
import 'import.dart';
import 'package:chatwhiz/mobile/notify.dart' as mn;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // 设置窗口参数（仅适用于桌面端）
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(1080, 620);
      appWindow.size = const Size(1080, 620);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    // 根据平台决定加载 桌面端 或 移动端 UI
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return _buildDesktopApp();
    } else {
      return _buildMobileApp();
    }
  }

  /// 构建桌面端应用
  Widget _buildDesktopApp() {
    return FluentApp(
      theme: FluentThemeData(
        brightness: Brightness.light,
        accentColor: Colors.blue,
      ),
      darkTheme: FluentThemeData(
        brightness: Brightness.dark,
        accentColor: Colors.blue,
      ),
      home: const DesktopHomePage(),
    );
  }

  /// 构建移动端应用
  Widget _buildMobileApp() {
    final String themeMode = box.read('themeMode') ?? 'system';
    final bool monetStatus = box.read('monetStatus') ?? true;
    final Color colorSeed = Color(box.read('colorSeed') ?? 0x6750A4);

    if (Platform.isIOS || !monetStatus) {
      // 如果Monet被禁用，使用默认配色
      final lightColorScheme = md.ColorScheme.fromSeed(
        seedColor: colorSeed,
      );
      final darkColorScheme = md.ColorScheme.fromSeed(
        seedColor: colorSeed,
        brightness: Brightness.dark,
      );

      return GetMaterialApp(
        scaffoldMessengerKey: mn.scaffoldMessengerKey,
        theme: md.ThemeData(colorScheme: lightColorScheme),
        darkTheme: md.ThemeData(colorScheme: darkColorScheme),
        themeMode: _getThemeMode(themeMode),
        home: const MobileHomePage(),
      );
    }

    return DynamicColorBuilder(
      builder: (md.ColorScheme? lightDynamic, md.ColorScheme? darkDynamic) {
        final lightColorScheme = lightDynamic?.harmonized() ??
            md.ColorScheme.fromSwatch(primarySwatch: md.Colors.blue);
        final darkColorScheme = darkDynamic?.harmonized() ??
            md.ColorScheme.fromSwatch(
              primarySwatch: md.Colors.blue,
              brightness: Brightness.dark,
            );

        return GetMaterialApp(
          scaffoldMessengerKey: mn.scaffoldMessengerKey,
          theme: md.ThemeData(colorScheme: lightColorScheme),
          darkTheme: md.ThemeData(colorScheme: darkColorScheme),
          themeMode: _getThemeMode(themeMode),
          home: const MobileHomePage(),
        );
      },
    );
  }

  /// 根据字符串返回 ThemeMode
  ThemeMode _getThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
