import 'package:chatwhiz/mobile/import.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> chatsList = [];
  final GetStorage _box = GetStorage();

  @override
  void initState() {
    super.initState();
    loadChats();
  }

  // 加载对话
  void loadChats() {
    List<dynamic> storedChats = _box.read<List>('chats') ?? [];
    chatsList = storedChats.map<Map<String, dynamic>>((dynamic chat) {
      return {
        "title": chat["title"],
        "subtitle": chat["subtitle"],
        "messages": (chat["messages"] as List<dynamic>)
            .map<Map<String, String>>((m) => Map<String, String>.from(m))
            .toList(),
      };
    }).toList();
  }

  // 删除对话
  void deleteChat(int index) {
    List<dynamic> storedChats = _box.read<List>('chats') ?? [];
    storedChats.removeAt(index); // 删除对应对话
    _box.write('chats', storedChats); // 更新存储
    loadChats(); // 刷新列表
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 20, bottom: 15),
              collapseMode: CollapseMode.parallax,
              title: Align(
                alignment: Alignment.bottomLeft,
                child: Text('ChatWhiz'),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final chat = chatsList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 14.0),
                  padding: const EdgeInsets.only(top: 2.0, bottom: 5.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          chat["title"] ?? "未知标题",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        subtitle: Text("模型：${chat["subtitle"] ?? '未知模型'}",
                            style: const TextStyle(fontSize: 14)),
                        onTap: () {
                          Get.off(() => Chat(
                                isNew: false,
                                choosenModel: chat["subtitle"],
                                existingMessages: chat["messages"],
                              ));
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // 删除对话
                            showDeleteDialog(context, index);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
              childCount: chatsList.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.off(() => Chat(
                isNew: true,
              ));
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(Icons.add,
            color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
    );
  }

  void showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("确认"),
          content: const Text("您确认删除该对话吗？"),
          actions: <Widget>[
            TextButton(
              child: const Text("取消"),
              onPressed: () {
                Get.back();
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  deleteChat(index);
                  Get.back();
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary),
              ),
              child: const Text("确认"),
            ),
          ],
        );
      },
    );
  }
}
