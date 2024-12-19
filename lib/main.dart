import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'import.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: 根据系统类型显示不同UI界面
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AndroidHomePage(),
    );
  }
}
