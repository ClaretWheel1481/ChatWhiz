import 'package:chatwhiz/mobile/import.dart';
import 'package:dio/dio.dart' as d;

class Chat extends StatefulWidget {
  final bool isNew;
  final String? choosenModel;
  final List<Map<String, String>>? existingMessages;
  const Chat(
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

  int reasonable = 0; // 0 = 不可用, 1 = 可用, 2 = 强制
  bool onReasonable = false;
  bool allowReasonable = false;
  List<Map<String, String>> _messages = [];
  String? selectedModel;
  bool isLoading = false;
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();

    // 翻译页面
    _languageCode = _box.read('languageCode') ?? 'en';
    Future.delayed(Duration.zero, () async {
      await FlutterI18n.refresh(context, Locale(_languageCode));
    });

    if (!widget.isNew && widget.existingMessages != null) {
      _messages = List<Map<String, String>>.from(widget.existingMessages!);
      selectedModel = widget.choosenModel!;
    }
    reasonable = AppConstants.reasonableCheck(selectedModel);
    reasonableStatus(reasonable);
    _scrollToBottom();
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

  // 滑动至最底部
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutSine,
        );
      }
    });
  }

  // 存储完整对话
  void _saveChatToStorage() {
    final storedChats = _box.read<List>('chats') ?? [];
    final chatTitle = _messages.isNotEmpty
        ? _messages.first["content"] ?? "unknown"
        : "New Chat";
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
    } catch (e) {
      showNotification(
          FlutterI18n.translate(context, "check_network_and_apikey"));
    }
  }

  // 发送
  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      isLoading = true;

      // 获取API地址
      final apiUrl = AppConstants.getAPI(selectedModel!);

      // 获取对应Token
      final apiKey = getAPIKey(selectedModel!);

      if (apiUrl.isEmpty || apiKey.isEmpty) {
        showNotification(FlutterI18n.translate(context, "check_apikey"));
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
      _saveChatToStorage();
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
      showNotification(FlutterI18n.translate(context, "input_content"));
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
                    Get.back();
                  },
            icon: const Icon(Icons.chevron_left),
          ),
          title: Align(
            alignment: Alignment.centerLeft,
            child: _messages.isEmpty
                ? Text(FlutterI18n.translate(context, "new_chat"))
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
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              _messages.isEmpty
                  ? Container(
                      margin: const EdgeInsets.all(5),
                      child: DropdownButtonFormField<String>(
                        value: selectedModel,
                        hint: Text(
                            FlutterI18n.translate(context, "choose_model")),
                        onChanged: widget.isNew
                            ? (String? newValue) {
                                setState(() {
                                  selectedModel = newValue!;
                                  reasonable = AppConstants.reasonableCheck(
                                      selectedModel);
                                  reasonableStatus(reasonable);
                                });
                              }
                            : null,
                        dropdownColor:
                            Theme.of(context).colorScheme.onSecondary,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(15)),
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                        items: AppConstants.models
                            .map<DropdownMenuItem<String>>((String model) {
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Text(model),
                          );
                        }).toList(),
                      ),
                    )
                  : Container(),
              Expanded(
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final message = _messages[index];
                          final isUser = message["role"] == "user";

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: isUser
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isUser)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15.0),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage: AssetImage(
                                          AppConstants.getImg(selectedModel!)),
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                          : Theme.of(context)
                                              .colorScheme
                                              .tertiaryContainer,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Markdown(
                                          data: message["content"] ?? "",
                                          selectable: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          styleSheet: MarkdownStyleSheet(
                                            p: const TextStyle(fontSize: 16.0),
                                            code:
                                                const TextStyle(fontSize: 14.0),
                                          ),
                                        ),
                                        // 如果是模型回复，则显示复制按钮
                                        if (!isUser)
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: IconButton(
                                              icon: const Icon(Icons.copy,
                                                  size: 20),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: message["content"] ??
                                                        ""));
                                                showNotification(
                                                    FlutterI18n.translate(
                                                        context,
                                                        "content_copied"));
                                              },
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (isUser)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 15.0),
                                    child: CircleAvatar(
                                      radius: 22,
                                      backgroundImage:
                                          AssetImage('assets/images/user.png'),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                        childCount: _messages.length,
                      ),
                    )
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.only(left: 8, right: 8, bottom: 20),
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
                        GestureDetector(
                          onTap: allowReasonable
                              ? null
                              : () => {
                                    setState(() {
                                      onReasonable = !onReasonable;
                                    })
                                  },
                          child: Row(
                            children: [
                              Checkbox(
                                  value: onReasonable,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  onChanged: allowReasonable
                                      ? null
                                      : (v) {
                                          setState(() {
                                            onReasonable = v!;
                                          });
                                        }),
                              Text(
                                FlutterI18n.translate(context, "reasoning"),
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
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
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.only(
                                      right: 40, top: 20, left: 10),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
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
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const SizedBox(height: 8),
                                                      Expanded(
                                                        child: TextField(
                                                          controller:
                                                              _controller,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16),
                                                          maxLines: null,
                                                          expands: true,
                                                          decoration:
                                                              const InputDecoration(
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
                                                            child: Text(
                                                                FlutterI18n
                                                                    .translate(
                                                                        context,
                                                                        "close")),
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
                        const SizedBox(width: 5),
                        isLoading
                            ? const CircularProgressIndicator()
                            : FilledButton(
                                onPressed: selectedModel != null &&
                                        selectedModel!.isNotEmpty
                                    ? _sendMessage
                                    : null,
                                child: Text(
                                    FlutterI18n.translate(context, "send")),
                              ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
