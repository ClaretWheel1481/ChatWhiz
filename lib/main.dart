import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'import.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux) {
    doWhenWindowReady(() {
      const initialSize = Size(1280, 960);
      appWindow.minSize = initialSize;
      appWindow.size = initialSize;
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
        title: 'ChatWhiz',
        theme: FluentThemeData(),
        home: const PCHomePage(),
      );
    } else {
      return GetMaterialApp(
        title: 'ChatWhiz',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const MobileHomePage(),
      );
    }
  }
}
