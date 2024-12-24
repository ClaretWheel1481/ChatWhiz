import 'package:chatwhiz/desktop/import.dart';

class Apikey extends StatefulWidget {
  const Apikey({super.key});

  @override
  State<Apikey> createState() => _ApikeyState();
}

class _ApikeyState extends State<Apikey> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
        header: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "API Key",
              style: FluentTheme.of(context)
                  .typography
                  .title
                  ?.copyWith(fontSize: 38),
            ),
          ),
        ),
        children: const [
          // TODO: 添加公告等部分界面
        ]);
  }
}
