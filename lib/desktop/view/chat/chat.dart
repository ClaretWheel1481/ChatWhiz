import 'package:chatwhiz/desktop/import.dart';
import 'package:chatwhiz/desktop/widgets/dialogs.dart';
import 'package:flutter/services.dart';

class AIChat extends StatefulWidget {
  bool isNew;
  String? choosenModel;
  List<Map<String, String>>? existingMessages;

  AIChat(
      {super.key,
      required this.isNew,
      this.existingMessages,
      this.choosenModel});

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  final GetStorage _box = GetStorage();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> _messages = [];
  String selectedModel = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isNew && widget.existingMessages != null) {
      _messages = List<Map<String, String>>.from(widget.existingMessages!);
      selectedModel = widget.choosenModel!;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _scrollToBottom();
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollToBottom();
        });
      });
    });
  }

  // 发送
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add({"role": "user", "content": _controller.text});

        // 滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 50), () {
            _scrollToBottom();
          });
        });

        // 发送后存储完整对话
        _saveChatToStorage();
        widget.isNew = false;

        // 清空输入框
        _controller.clear();
      });
      isLoading = true;
      // 获取API地址
      String apiUrl = AppConstants.getAPI(selectedModel);
      if (apiUrl.isNotEmpty) {
        await _fetchAIResponse(apiUrl);
      } else {
        print("未找到对应的 API 地址！");
      }
      setState(() {
        // 滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 50), () {
            _scrollToBottom();
            Future.delayed(const Duration(milliseconds: 100), () {
              _scrollToBottom();
            });
          });
        });
        isLoading = false;
      });
    } else {
      show1ButtonDialog(context, "内容为空", () {
        Navigator.pop(context);
      });
    }
  }

  // 存储完整对话
  void _saveChatToStorage() {
    List<dynamic> storedChats = _box.read<List>('chats') ?? [];

    // 如果是新对话，则创建新记录
    if (widget.isNew) {
      storedChats.add({
        "title": _messages.isNotEmpty ? _messages.first["content"] : "新对话",
        "subtitle": selectedModel,
        "messages": _messages, // 存储完整对话
      });
    } else {
      // 查找当前对话并更新
      for (var chat in storedChats) {
        if (chat["title"] ==
            (_messages.isNotEmpty ? _messages.first["content"] : "")) {
          chat["messages"] = _messages;
          break;
        }
      }
    }

    // 存入 GetStorage
    _box.write('chats', storedChats);
  }

  // TODO: 实现请求模型API(需要做额外适配)（代理功能）
  Future<void> _fetchAIResponse(String apiUrl) async {
    print("调用 API: $apiUrl");
    try {
      final data = {"model": selectedModel, "messages": _messages};
      Response resp = await Dio().post(apiUrl,
          data: data,
          options: Options(headers: {
            'Authorization': 'Bearer ${_box.read('ZhipuKey')}',
            'Content-Type': 'application/json',
          }));
      print(resp);
      print(resp.data['choices'][0]['message']);
      _messages.add({
        'content': resp.data['choices'][0]['message']['content'],
        'role': resp.data['choices'][0]['message']['role'],
      });
      _saveChatToStorage();
    } catch (e) {
      print("Error:$e");
    }
  }

  // 滑动至最底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ContentDialog(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              maxHeight: MediaQuery.of(context).size.height),
          title: Row(
            children: [
              IconButton(
                  style: const ButtonStyle(
                      iconSize: WidgetStatePropertyAll(22.0),
                      padding:
                          WidgetStatePropertyAll(EdgeInsets.only(right: 10))),
                  icon: const Icon(FluentIcons.back),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              Text(
                widget.isNew ? "新对话" : "对话",
                style: FluentTheme.of(context)
                    .typography
                    .title
                    ?.copyWith(fontSize: 38),
              ),
            ],
          ),
          content: Column(
            children: [
              Row(
                children: [
                  const Text("选择模型："),
                  ComboBox<String>(
                    value: selectedModel,
                    items: AppConstants.models.map((e) {
                      return ComboBoxItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: widget.isNew
                        ? (model) => setState(() => selectedModel = model!)
                        : null,
                    placeholder: const Text("选择对话模型"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message["role"] == "user"; // 判断是否是用户发送的消息

                    return Align(
                      alignment:
                          isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 10),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color.fromARGB(255, 27, 154, 255)
                              : Colors.purple,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(15),
                            topRight: const Radius.circular(15),
                            bottomLeft: isUser
                                ? const Radius.circular(15)
                                : Radius.zero,
                            bottomRight: isUser
                                ? Radius.zero
                                : const Radius.circular(15),
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: SelectableText(
                          message["content"] ?? "",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 18),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        IconButton(
                            icon: const Icon(FluentIcons.add),
                            onPressed: () {}),
                        const SizedBox(
                          width: 5,
                        ),
                        // TODO: 限制为部分模型使用
                        const Button(
                          onPressed: null,
                          child: Text('推理'),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        // TODO: 限制为部分模型使用
                        const Button(
                          onPressed: null,
                          child: Text('联网搜索'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                            child: Focus(
                          onKeyEvent: (node, event) {
                            if (event is KeyDownEvent &&
                                event.logicalKey == LogicalKeyboardKey.enter) {
                              if (HardwareKeyboard.instance.isShiftPressed) {
                                // Shift + Enter换行
                              } else {
                                // 回车发送消息
                                _sendMessage();
                                return KeyEventResult.handled;
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: TextBox(
                            enabled: selectedModel.isNotEmpty,
                            controller: _controller,
                            placeholder: '输入内容...',
                            maxLines: 5,
                            style: const TextStyle(fontSize: 16),
                          ),
                        )),
                        const SizedBox(width: 8),
                        isLoading
                            ? const ProgressRing()
                            : FilledButton(
                                onPressed: selectedModel.isNotEmpty
                                    ? _sendMessage
                                    : null,
                                child: const Text('发送'),
                              ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(
          height: 42,
          width: MediaQuery.of(context).size.width,
          child: MoveWindow(),
        )
      ],
    );
  }
}
