import 'package:chatwhiz/mobile/import.dart';
import 'package:dio/dio.dart' as d;

class Chat extends StatefulWidget {
  bool isNew;
  String? choosenModel;
  List<Map<String, String>>? existingMessages;
  Chat(
      {super.key,
      required this.isNew,
      this.choosenModel,
      this.existingMessages});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final GetStorage _box = GetStorage();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();

  List<Map<String, String>> _messages = [];
  String? selectedModel;
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

  // 获取对应模型的APIKey
  String getAPIKey(String model) {
    if (AppConstants.dsModels.contains(model)) return _box.read('DSKey') ?? '';
    if (AppConstants.qwenModels.contains(model))
      return _box.read('QwenKey') ?? '';
    if (AppConstants.openAIModels.contains(model))
      return _box.read('OpenAIKey') ?? '';
    if (AppConstants.zhipuModels.contains(model))
      return _box.read('ZhipuKey') ?? '';
    return '';
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

  // TODO: 实现请求模型API(需要做额外适配，如图像处理)
  Future<void> _fetchAIResponse(String apiUrl, apiKey) async {
    try {
      final data = {"model": selectedModel, "messages": _messages};
      d.Response resp = await d.Dio().post(apiUrl,
          data: data,
          options: d.Options(headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          }));
      print(resp);
      _messages.add({
        'content': resp.data['choices'][0]['message']['content'],
        'role': resp.data['choices'][0]['message']['role'],
      });
      _saveChatToStorage();
    } catch (e) {
      showNotification("请检查您的网络设置以及APIKey填写是否正确！");
    }
  }

  // 发送
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      isLoading = true;

      // 获取API地址
      String apiUrl = AppConstants.getAPI(selectedModel!);

      // 获取对应Token
      String apiKey = getAPIKey(selectedModel!);
      if (apiUrl.isNotEmpty && apiKey.isNotEmpty) {
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
        await _fetchAIResponse(apiUrl, apiKey);
      } else {
        showNotification("请确保对应模型的APIKey已经填写。");
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
      showNotification("内容为空。");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Get.off(() => const MobileHomePage());
                        },
                  icon: const Icon(Icons.chevron_left)),
              title: Align(
                alignment: Alignment.centerLeft,
                child: widget.isNew
                    ? const Text(
                        "新对话",
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _messages.first["content"]!,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            selectedModel!,
                            style: const TextStyle(fontSize: 12),
                          )
                        ],
                      ),
              ),
            ),
            body: Column(
              children: [
                widget.isNew
                    ? Container(
                        margin: const EdgeInsets.all(5),
                        child: DropdownButtonFormField<String>(
                          value: selectedModel,
                          hint: const Text('请选择模型'),
                          onChanged: widget.isNew
                              ? (String? newValue) {
                                  setState(() {
                                    selectedModel = newValue!;
                                  });
                                }
                              : null,
                          dropdownColor:
                              Theme.of(context).colorScheme.onSecondary,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder()),
                          items:
                              AppConstants.models.map<DropdownMenuItem<String>>(
                            (String model) {
                              return DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              );
                            },
                          ).toList(),
                        ),
                      )
                    : Container(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message["role"] == "user"; // 判断是否是用户发送的消息

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 14),
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 15),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context)
                                    .colorScheme
                                    .tertiaryContainer,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(20),
                              topRight: const Radius.circular(20),
                              bottomLeft: isUser
                                  ? const Radius.circular(20)
                                  : Radius.zero,
                              bottomRight: isUser
                                  ? Radius.zero
                                  : const Radius.circular(20),
                            ),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.7,
                          ),
                          // TODO: 替换为可显示Markdown语法的组件，以及一键复制功能
                          child: SelectableText(
                            message["content"] ?? "",
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(
                      top: 4, left: 8, right: 8, bottom: 10),
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: const Icon(Icons.add), onPressed: () {}),
                          const SizedBox(
                            width: 5,
                          ),
                          // TODO: 限制为部分模型使用
                          const ElevatedButton(
                            onPressed: null,
                            child: Row(
                              children: [Icon(Icons.lightbulb), Text('推理')],
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          // TODO: 限制为部分模型使用
                          const ElevatedButton(
                            onPressed: null,
                            child: Row(
                              children: [
                                Icon(Icons.wb_cloudy_rounded),
                                Text('联网')
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                TextField(
                                  enabled: selectedModel != null &&
                                      selectedModel!.isNotEmpty,
                                  controller: _controller,
                                  maxLines: 2,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: const InputDecoration(
                                      contentPadding: EdgeInsets.only(
                                        right: 40,
                                        top: 20,
                                        left: 10,
                                      ),
                                      labelText: "输入内容",
                                      border: OutlineInputBorder()),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.zoom_out_map),
                                    onPressed: selectedModel != null &&
                                            selectedModel!.isNotEmpty
                                        ? () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return Dialog(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const SizedBox(
                                                            height: 8),
                                                        Expanded(
                                                          child: TextField(
                                                            controller:
                                                                _controller,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        16),
                                                            maxLines: null,
                                                            expands: true,
                                                            decoration:
                                                                const InputDecoration(
                                                              labelText: "输入内容",
                                                              border:
                                                                  OutlineInputBorder(),
                                                            ),
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Get.back();
                                                              },
                                                              child: const Text(
                                                                  "关闭"),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          isLoading
                              ? const CircularProgressIndicator()
                              : FilledButton(
                                  onPressed: selectedModel != null &&
                                          selectedModel!.isNotEmpty
                                      ? _sendMessage
                                      : null,
                                  child: const Text('发送'),
                                ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            )));
  }
}
