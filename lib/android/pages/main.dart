import 'package:flutter/material.dart';

class AndroidHomePage extends StatefulWidget {
  const AndroidHomePage({super.key});

  @override
  State<AndroidHomePage> createState() => _AndroidHomePageState();
}

class _AndroidHomePageState extends State<AndroidHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}
