import 'package:chatwhiz/mobile/import.dart';
import 'import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return _buildMobileApp();
  }

  /// 构建移动端应用
  Widget _buildMobileApp() {
    final String themeMode = box.read('themeMode') ?? 'system';
    final bool monetStatus = box.read('monetStatus') ?? true;
    final Color colorSeed = Color(box.read('colorSeed') ?? 0x6750A4);
    final String languageCode = box.read('languageCode') ?? 'en';

    if (Platform.isIOS || !monetStatus) {
      // 如果Monet被禁用，使用默认配色
      final lightColorScheme = ColorScheme.fromSeed(
        seedColor: colorSeed,
      );
      final darkColorScheme = ColorScheme.fromSeed(
        seedColor: colorSeed,
        brightness: Brightness.dark,
      );

      return GetMaterialApp(
        locale: Locale(languageCode),
        fallbackLocale: const Locale('en'),
        localizationsDelegates: [
          FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                  useCountryCode: true, basePath: 'assets/locales'),
              missingTranslationHandler: (key, locale) {
                showNotification("i18n loading error");
              }),
        ],
        scaffoldMessengerKey: scaffoldMessengerKey,
        theme: ThemeData(colorScheme: lightColorScheme),
        darkTheme: ThemeData(colorScheme: darkColorScheme),
        themeMode: _getThemeMode(themeMode),
        home: const MobileHomePage(),
      );
    }

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightColorScheme = lightDynamic?.harmonized() ??
            ColorScheme.fromSwatch(primarySwatch: Colors.blue);
        final darkColorScheme = darkDynamic?.harmonized() ??
            ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              brightness: Brightness.dark,
            );

        return GetMaterialApp(
          locale: Locale(languageCode),
          fallbackLocale: const Locale('en'),
          localizationsDelegates: [
            FlutterI18nDelegate(
                translationLoader: FileTranslationLoader(
                    useCountryCode: true, basePath: 'assets/locales'),
                missingTranslationHandler: (key, locale) {
                  showNotification("i18n loading error");
                }),
          ],
          scaffoldMessengerKey: scaffoldMessengerKey,
          theme: ThemeData(colorScheme: lightColorScheme),
          darkTheme: ThemeData(colorScheme: darkColorScheme),
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
