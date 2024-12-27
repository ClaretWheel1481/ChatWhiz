import 'package:chatwhiz/desktop/import.dart';

class AIChat extends StatefulWidget {
  bool? isNew;

  AIChat({Key? key, required this.isNew}) : super(key: key);

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  final GetStorage _box = GetStorage();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  String selectedModel = '';

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        widget.isNew = false;
        _messages.add(_controller.text);
        // TODO: 等待模型回复后保存一次对话内容
        _scrollToBottom();
        _controller.clear();
      });
    } else {
      showCheckDialog(context);
    }
  }

  // 空对话框
  void showCheckDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('内容为空'),
        actions: [
          Button(
            child: const Text('是'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
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
                "对话",
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
                  ComboBox<String>(
                    value: selectedModel,
                    items: AppConstants.models.map((e) {
                      return ComboBoxItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                    onChanged: widget.isNew!
                        ? (model) => setState(() => selectedModel = model!)
                        : null,
                    placeholder: const Text("选择对话模型"),
                  ),
                ],
              ),
              // TODO: 优化对话内容样式
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        _messages[index],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextBox(
                        enabled: selectedModel.isNotEmpty ? true : false,
                        controller: _controller,
                        placeholder: '输入内容...',
                        maxLines: 5,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: _controller.text.isEmpty ? null : _sendMessage,
                      child: const Text('发送'),
                    ),
                  ],
                ),
              ),
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
