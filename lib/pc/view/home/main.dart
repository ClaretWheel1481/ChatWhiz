import 'package:chatwhiz/pc/import.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    final userName = Platform.environment['USERNAME'] ?? '用户';
    if (hour < 11 && hour > 5) {
      return '早上好, $userName！';
    } else if (hour < 14 && hour >= 11) {
      return '中午好, $userName！';
    } else if (hour < 18 && hour >= 14) {
      return '下午好，$userName！';
    } else {
      return '晚上好, $userName！';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
        header: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              getGreeting(),
              style: FluentTheme.of(context)
                  .typography
                  .title
                  ?.copyWith(fontSize: 38),
            ),
          ),
        ),
        children: const []);
  }
}
