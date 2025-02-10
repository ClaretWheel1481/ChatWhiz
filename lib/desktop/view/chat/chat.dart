import 'package:chatwhiz/desktop/import.dart';

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

  int reasonable = 0; // 0 = 不可用, 1 = 可用, 2 = 强制
  bool onReasonable = false;
  bool allowReasonable = false;
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
    reasonableStatus(AppConstants.reasonableCheck(selectedModel));
  }

  // 推理逻辑检查
  void reasonableStatus(int r) {
    if (r == 1) {
      onReasonable = true;
      allowReasonable = false;
    } else if (r == 2) {
      onReasonable = true;
      allowReasonable = true;
    } else {
      onReasonable = false;
      allowReasonable = true;
    }
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

  // 发送
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      isLoading = true;

      // 获取API地址
      String apiUrl = AppConstants.getAPI(selectedModel);

      // 获取对应Token
      String apiKey = getAPIKey(selectedModel);
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
        showNotification(
            context, "参数错误", "请确保对应模型的APIKey已经填写。", InfoBarSeverity.error);
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

  // TODO: 实现请求模型API(需要做额外适配，如图像处理)
  Future<void> _fetchAIResponse(String apiUrl, apiKey) async {
    Dio dio = Dio();

    // 配置代理
    if (_box.read('proxy') ?? false) {
      var proxySettings = _box.read('proxySettings');
      String ip = proxySettings['ip'];
      int port = proxySettings['port'];

      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          HttpClient client = HttpClient();
          client.findProxy = (uri) {
            // 设置代理地址
            return 'PROXY $ip:$port;';
          };
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );
    }

    try {
      final data = {"model": selectedModel, "messages": _messages};
      Response resp = await dio.post(apiUrl,
          data: data,
          options: Options(headers: {
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
      showNotification(
          context, "请求错误", "检查您的网络设置以及APIKey填写是否正确！", InfoBarSeverity.error);
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
                      padding: WidgetStatePropertyAll(EdgeInsets.all(12))),
                  icon: const Icon(FluentIcons.back),
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        }),
              widget.isNew
                  ? Text(
                      "新对话",
                      style: FluentTheme.of(context)
                          .typography
                          .title
                          ?.copyWith(fontSize: 34),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_messages.first["content"]!),
                        Text(
                          selectedModel,
                          style: const TextStyle(fontSize: 13),
                        )
                      ],
                    ),
            ],
          ),
          content: Column(
            children: [
              Row(
                children: [
                  widget.isNew
                      ? ComboBox<String>(
                          value: selectedModel,
                          items: AppConstants.models.map((e) {
                            return ComboBoxItem(
                              value: e,
                              child: Text(e),
                            );
                          }).toList(),
                          onChanged: (model) => setState(() {
                            selectedModel = model!;
                            reasonable =
                                AppConstants.reasonableCheck(selectedModel);
                            reasonableStatus(reasonable);
                          }),
                          placeholder: const Text("选择对话模型"),
                        )
                      : Container(),
                ],
              ),
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
                            vertical: 5, horizontal: 5),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
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
                        child: Column(
                          children: [
                            Markdown(
                              data: message["content"] ?? "",
                              selectable: true,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              styleSheet: MarkdownStyleSheet(
                                  p: const TextStyle(fontSize: 16.0),
                                  code: const TextStyle(fontSize: 14.0)),
                            ),
                            // 复制按钮
                            isUser
                                ? Container()
                                : Align(
                                    alignment: Alignment.bottomRight,
                                    child: IconButton(
                                      icon: const Icon(FluentIcons.copy,
                                          size: 20),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(
                                            text: message["content"] ?? ""));
                                        showNotification(context, "通知",
                                            "内容已复制。", InfoBarSeverity.success);
                                      },
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
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
                        Checkbox(
                          checked: onReasonable,
                          onChanged: allowReasonable
                              ? null
                              : (v) {
                                  setState(() {
                                    onReasonable = v!;
                                  });
                                },
                          content: Text("推理"),
                        )
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
                            maxLines: 3,
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
