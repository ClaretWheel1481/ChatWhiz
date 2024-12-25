import 'package:chatwhiz/desktop/import.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GetStorage _box = GetStorage();

  // 保存对话列表
  // TODO: 用List显示，标题以用户发起的第一个问题，副标题为选择的对话
  List<String> chatsList = [];

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
        header: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "对话",
              style: FluentTheme.of(context)
                  .typography
                  .title
                  ?.copyWith(fontSize: 38),
            ),
          ),
        ),
        content: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text("无对话"),
              HyperlinkButton(
                child: const Text("新增对话"),
                onPressed: () {
                  showDialog(
                      context: context, builder: (context) => const AIChat());
                },
              ),
            ],
          ),
        ));
  }
}
