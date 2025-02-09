import 'package:chatwhiz/mobile/import.dart';
import 'package:chatwhiz/mobile/view/home/controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.loadChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<HomeController>(builder: (controller) {
        return CustomScrollView(
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
                  final chat = controller.chatsList[index];
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
                            Get.to(() => Chat(
                                  isNew: false,
                                  choosenModel: chat["subtitle"],
                                  existingMessages: chat["messages"],
                                ));
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // 删除对话
                              controller.deleteChat(index);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                childCount: controller.chatsList.length, // 指定列表项数量
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => Chat(
                isNew: true,
              ));
        },
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        child: Icon(Icons.add,
            color: Theme.of(context).colorScheme.onPrimaryContainer),
      ),
    );
  }
}
