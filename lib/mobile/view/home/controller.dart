import 'package:chatwhiz/mobile/import.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  List<Map<String, dynamic>> chatsList = [];
  final GetStorage _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadChats(); // 初始化加载聊天数据
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
    update();
  }

  // 删除对话
  void deleteChat(int index) {
    List<dynamic> storedChats = _box.read<List>('chats') ?? [];
    storedChats.removeAt(index); // 删除对应对话
    _box.write('chats', storedChats); // 更新存储
    loadChats(); // 刷新列表
  }

  void refreshChats() {
    loadChats(); // 重新加载聊天数据
  }
}
