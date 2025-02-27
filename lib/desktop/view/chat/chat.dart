import 'package:chatwhiz/desktop/import.dart';

class AIChat extends StatefulWidget {
  final bool isNew;
  final String? choosenModel;
  final List<Map<String, String>>? existingMessages;

  const AIChat(
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
    setState(() {
      onReasonable = (r == 1 || r == 2);
      // 当 r==1 时，不允许修改推理状态，其他情况允许
      allowReasonable = (r != 1);
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

  // 发送
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      isLoading = true;

      // 获取API地址
      final apiUrl = AppConstants.getAPI(selectedModel);

      // 获取对应Token
      final apiKey = getAPIKey(selectedModel);

      if (apiUrl.isEmpty || apiKey.isEmpty) {
        showNotification(
            context, "参数错误", "请确保对应模型的APIKey已经填写。", InfoBarSeverity.error);
        setState(() => isLoading = false);
        return;
      }
      setState(() {
        _messages.add({"role": "user", "content": _controller.text});

        // 滚动到底部
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 50), () {
            _scrollToBottom();
          });
        });

        // 清空输入框
        _controller.clear();
      });
      await _fetchAIResponse(apiUrl, apiKey);
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
    final storedChats = _box.read<List>('chats') ?? [];
    final chatTitle =
        _messages.isNotEmpty ? _messages.first["content"] ?? "新对话" : "新对话";
    if (widget.isNew) {
      storedChats.add({
        "title": chatTitle,
        "subtitle": selectedModel,
        "messages": _messages,
      });
    } else {
      final index =
          storedChats.indexWhere((chat) => chat["title"] == chatTitle);
      if (index != -1) {
        storedChats[index]["messages"] = _messages;
      }
    }
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
          duration: const Duration(milliseconds: 400),
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
              _messages.isEmpty
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
                  _messages.isEmpty
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
                    final avatarUrl = isUser
                        ? "assets/images/user.png"
                        : AppConstants.getImg(selectedModel);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: Row(
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            CircleAvatar(
                              backgroundImage: AssetImage(avatarUrl),
                              radius: 20,
                              backgroundColor:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.transparent,
                            ),
                            const SizedBox(width: 10),
                          ],
                          // 消息内容
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? const Color.fromARGB(255, 27, 154, 255)
                                    : Colors.purple.withAlpha(233),
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(15)),
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.7,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Markdown(
                                    data: message["content"] ?? "",
                                    selectable: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    styleSheet: MarkdownStyleSheet(
                                      a: TextStyle(
                                        fontSize: 16.0,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      h1: TextStyle(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      h2: TextStyle(
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      p: TextStyle(
                                        fontSize: 16.0,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                      code: TextStyle(
                                        fontSize: 14.0,
                                        color: MediaQuery.of(context)
                                                    .platformBrightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  // 复制按钮，仅对 AI 消息显示
                                  if (!isUser) ...[
                                    Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: const Icon(FluentIcons.copy,
                                            size: 20),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: message["content"] ?? ""));
                                          showNotification(
                                              context,
                                              "通知",
                                              "内容已复制。",
                                              InfoBarSeverity.success);
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 10),
                            CircleAvatar(
                              backgroundImage: AssetImage(avatarUrl),
                              radius: 20,
                            ),
                          ],
                        ],
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
                          content: const Text("推理"),
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
