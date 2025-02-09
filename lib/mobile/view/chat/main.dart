import 'dart:io';

import 'package:chatwhiz/mobile/import.dart';
import 'package:chatwhiz/mobile/view/home/controller.dart';
import 'package:dio/dio.dart' as d;
import 'package:dio/io.dart';

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

  // TODO: 实现请求模型API(需要做额外适配，如图像处理)（代理）
  Future<void> _fetchAIResponse(String apiUrl, apiKey) async {
    d.Dio dio = d.Dio();

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
      d.Response resp = await dio.post(apiUrl,
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
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Get.find<HomeController>().loadChats();
                          Get.back();
                        },
                  icon: const Icon(Icons.chevron_left)),
              title: Text(
                widget.isNew ? "新对话" : "对话",
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedModel,
                    hint: const Text('请选择模型'),
                    onChanged: widget.isNew
                        ? (String? newValue) {
                            setState(() {
                              selectedModel = newValue!;
                            });
                          }
                        : null,
                    dropdownColor: Theme.of(context).colorScheme.onSecondary,
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    items: AppConstants.models.map<DropdownMenuItem<String>>(
                      (String model) {
                        return DropdownMenuItem<String>(
                          value: model,
                          child: Text(model),
                        );
                      },
                    ).toList(),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser =
                            message["role"] == "user"; // 判断是否是用户发送的消息

                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 14),
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                  : Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
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
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 5),
                  Column(
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
                            child: Text('推理'),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          // TODO: 限制为部分模型使用
                          const ElevatedButton(
                            onPressed: null,
                            child: Text('联网搜索'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              enabled: selectedModel != null &&
                                  selectedModel!.isNotEmpty,
                              controller: _controller,
                              maxLines: 5,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                  labelText: "输入内容...",
                                  border: OutlineInputBorder()),
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
                  )
                ],
              ),
            )));
  }
}
