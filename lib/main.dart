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
      // 读取主题模式和 Monet 状态
      final GetStorage box = GetStorage();
      final String themeMode = box.read('themeMode') ?? 'system';
      final bool monetStatus = box.read('monetStatus') ?? true;

      // 如果 Monet 被禁用，使用默认配色
      if (!monetStatus) {
        final lightColorScheme =
            md.ColorScheme.fromSwatch(primarySwatch: md.Colors.blue);
        final darkColorScheme = md.ColorScheme.fromSwatch(
          primarySwatch: md.Colors.blue,
          brightness: Brightness.dark,
        );

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
      }

      // 如果 Monet 被启用，使用动态取色
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
              primarySwatch: md.Colors.blue,
              brightness: Brightness.dark,
            );
          }

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
