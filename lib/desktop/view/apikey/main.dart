import 'package:chatwhiz/desktop/import.dart';

class Apikey extends StatefulWidget {
  const Apikey({super.key});

  @override
  State<Apikey> createState() => _ApikeyState();
}

class _ApikeyState extends State<Apikey> {
  final GetStorage _box = GetStorage();
  final TextEditingController QwenKey = TextEditingController();
  final TextEditingController OpenAIKey = TextEditingController();
  final TextEditingController ZhipuKey = TextEditingController();

  @override
  void initState() {
    QwenKey.text = _box.read('QwenKey') ?? '';
    OpenAIKey.text = _box.read('OpenAIKey') ?? '';
    ZhipuKey.text = _box.read('ZhipuKey') ?? '';
    super.initState();
  }

  // Key持久化
  void keySaved() {
    _box.write('QwenKey', QwenKey.text);
    _box.write('OpenAIKey', OpenAIKey.text);
    _box.write('ZhipuKey', ZhipuKey.text);
    showSaved(context);
  }

  // 保存对话框
  void showSaved(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('保存成功'),
        actions: [
          FilledButton(
            child: const Text('好'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
        header: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "API Key",
              style: FluentTheme.of(context)
                  .typography
                  .title
                  ?.copyWith(fontSize: 38),
            ),
          ),
        ),
        children: [
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('千问API Key'),
              const SizedBox(width: 10),
              HyperlinkButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                        'https://help.aliyun.com/zh/model-studio/getting-started/first-api-call-to-qwen'));
                  },
                  child: const Text("如何获取？"))
            ],
          ),
          TextBox(
            controller: QwenKey,
            expands: false,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('OpenAIAPI Key'),
              const SizedBox(width: 10),
              HyperlinkButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                        'https://platform.openai.com/docs/quickstart?language-preference=curl&quickstart-example'));
                  },
                  child: const Text("如何获取？"))
            ],
          ),
          TextBox(
            controller: OpenAIKey,
            expands: false,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('智谱API Key'),
              const SizedBox(width: 10),
              HyperlinkButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                        'https://bigmodel.cn/usercenter/proj-mgmt/apikeys'));
                  },
                  child: const Text("如何获取？"))
            ],
          ),
          TextBox(
            controller: ZhipuKey,
            expands: false,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton(
                onPressed: () {
                  keySaved();
                },
                child: const Text("保存"),
              )
            ],
          ),
        ]);
  }
}
