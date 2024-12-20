import 'package:flutter/material.dart' as md;
import 'package:get/get.dart';
import 'import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  if (Platform.isWindows || Platform.isLinux) {
    doWhenWindowReady(() {
      appWindow.minSize = const Size(1080, 620);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows || Platform.isLinux) {
      return FluentApp(
        theme: FluentThemeData(),
        home: const PCHomePage(),
      );
    } else {
      // 读取并应用主题模式
      final GetStorage box = GetStorage();
      final String themeMode = box.read('themeMode') ?? 'system';

      // 获取Material Design Color
      return DynamicColorBuilder(
        builder: (md.ColorScheme? lightDynamic, md.ColorScheme? darkDynamic) {
          md.ColorScheme lightColorScheme;
          md.ColorScheme darkColorScheme;

          if (lightDynamic != null && darkDynamic != null) {
            lightColorScheme = lightDynamic.harmonized();
            darkColorScheme = darkDynamic.harmonized();
          } else {
            lightColorScheme =
                md.ColorScheme.fromSwatch(primarySwatch: md.Colors.blue);
            darkColorScheme = md.ColorScheme.fromSwatch(
                primarySwatch: md.Colors.blue, brightness: Brightness.dark);
          }

          // 应用程序总入口
          return GetMaterialApp(
            theme: md.ThemeData(colorScheme: lightColorScheme),
            darkTheme: md.ThemeData(colorScheme: darkColorScheme),
            themeMode: themeMode == 'system'
                ? ThemeMode.system
                : themeMode == 'light'
                    ? ThemeMode.light
                    : ThemeMode.dark,
            home: const MobileHomePage(),
          );
        },
      );
    }
  }
}
