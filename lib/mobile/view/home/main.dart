import 'package:chatwhiz/mobile/import.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> chatsList = [];
  final GetStorage _box = GetStorage();
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();
    // 翻译页面
    _languageCode = _box.read('languageCode') ?? 'en';
    Future.delayed(Duration.zero, () {
      FlutterI18n.refresh(context, Locale(_languageCode));
    });
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
                          chat["title"] ??
                              FlutterI18n.translate(context, "unknown"),
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                            "${FlutterI18n.translate(context, "model")}：${chat["subtitle"] ?? FlutterI18n.translate(context, "unknown")}",
                            style: const TextStyle(fontSize: 14)),
                        onTap: () {
                          Get.to(() => Chat(
                                    isNew: false,
                                    choosenModel: chat["subtitle"],
                                    existingMessages: chat["messages"],
                                  ))!
                              .then((_) {
                            loadChats();
                            setState(() {});
                          });
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
          Get.to(() => const Chat(
                    isNew: true,
                  ))!
              .then((_) {
            loadChats();
            setState(() {});
          });
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
          title: Text(FlutterI18n.translate(context, "confirm")),
          content: Text(FlutterI18n.translate(
              context, "are_you_sure_to_delete_this_conversation")),
          actions: <Widget>[
            TextButton(
              child: Text(FlutterI18n.translate(context, "cancel")),
              onPressed: () {
                Get.back();
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  deleteChat(index);
                  Get.back();
                  showNotification(FlutterI18n.translate(context, "success"));
                });
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.primary),
                foregroundColor: WidgetStatePropertyAll(
                    Theme.of(context).colorScheme.onPrimary),
              ),
              child: Text(FlutterI18n.translate(context, "ok")),
            ),
          ],
        );
      },
    );
  }
}
