import 'package:chatwhiz/desktop/import.dart';

class AIChat extends StatefulWidget {
  const AIChat({Key? key}) : super(key: key);

  @override
  State<AIChat> createState() => _AIChatState();
}

class _AIChatState extends State<AIChat> {
  final GetStorage _box = GetStorage();
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  String? selectedModel = 'Qwen';

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _messages.add(_controller.text);
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height),
      title: Row(
        children: [
          IconButton(
              style: const ButtonStyle(
                  iconSize: WidgetStatePropertyAll(22.0),
                  padding: WidgetStatePropertyAll(EdgeInsets.only(right: 10))),
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
              const Text("选择对话模型："),
              ComboBox<String>(
                value: selectedModel,
                items: AppConstants.models.map((e) {
                  return ComboBoxItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (color) => setState(() => selectedModel = color),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
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
                    controller: _controller,
                    placeholder: '输入内容...',
                    maxLines: 5,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _sendMessage,
                  child: const Text('发送'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
