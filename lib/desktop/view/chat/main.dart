import 'package:chatwhiz/desktop/import.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GetStorage _box = GetStorage();
  List<Map<String, dynamic>> chatsList = [];

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  // 加载对话
  void _loadChats() {
    List<dynamic> storedChats = _box.read<List>('chats') ?? [];
    setState(() {
      chatsList = storedChats.map<Map<String, dynamic>>((dynamic chat) {
        return {
          "title": chat["title"],
          "subtitle": chat["subtitle"],
          "messages": (chat["messages"] as List<dynamic>)
              .map<Map<String, String>>((m) => Map<String, String>.from(m))
              .toList(),
        };
      }).toList();
    });
  }

  // 删除对话
  void deleteChat(int index) {
    List<dynamic> storedChats = _box.read<List>('chats') ?? [];
    storedChats.removeAt(index); // 删除对应对话
    _box.write('chats', storedChats); // 更新存储
    _loadChats(); // 刷新列表
  }

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
        content: chatsList.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("无对话"),
                    HyperlinkButton(
                      child: const Text("新增对话"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AIChat(isNew: true),
                        ).then((_) {
                          _loadChats();
                        });
                      },
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: chatsList.length,
                itemBuilder: (context, index) {
                  final chat = chatsList[index];
                  return Container(
                    padding: const EdgeInsets.only(left: 5, top: 12, right: 5),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            chat["title"] ?? "未知标题",
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text("模型：${chat["subtitle"] ?? '未知模型'}",
                              style: const TextStyle(fontSize: 14)),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AIChat(
                                isNew: false,
                                choosenModel: chat["subtitle"],
                                existingMessages: chat["messages"],
                              ),
                            ).then((_) {
                              _loadChats(); // 刷新列表
                            });
                          },
                          trailing: IconButton(
                            icon: const Icon(FluentIcons.delete),
                            onPressed: () {
                              // 删除对话
                              show2ButtonsDialog(
                                  context, '你确定删除吗？', '删除后，该对话内容将无法恢复。', () {
                                deleteChat(index);
                                Navigator.pop(context);
                                showNotification(context, "删除成功", "该对话已经成功删除。",
                                    InfoBarSeverity.success);
                              }, () {
                                Navigator.pop(context);
                              });
                            },
                          ),
                        ),
                        const Divider()
                      ],
                    ),
                  );
                },
              ),
        bottomBar: chatsList.isNotEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: FilledButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AIChat(isNew: true),
                            ).then((_) {
                              _loadChats();
                            });
                          },
                          child: const Icon(FluentIcons.add),
                        ),
                      ))
                ],
              )
            : null);
  }
}
