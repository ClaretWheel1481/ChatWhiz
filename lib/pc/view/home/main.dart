import 'package:chatwhiz/import.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(children: const [
      Text('主页'),
    ]);
  }
}
