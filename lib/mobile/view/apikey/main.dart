import 'package:chatwhiz/mobile/import.dart';

class ApiKey extends StatefulWidget {
  const ApiKey({super.key});

  @override
  State<ApiKey> createState() => _ApiKeyState();
}

class _ApiKeyState extends State<ApiKey> {
  final GetStorage _box = GetStorage();
  final TextEditingController QwenKey = TextEditingController();
  final TextEditingController OpenAIKey = TextEditingController();
  final TextEditingController ZhipuKey = TextEditingController();
  final TextEditingController DSKey = TextEditingController();
  String _languageCode = 'en';

  @override
  void initState() {
    super.initState();
    // 翻译页面
    _languageCode = _box.read('languageCode') ?? 'en';
    Future.delayed(Duration.zero, () async {
      await FlutterI18n.refresh(context, Locale(_languageCode));
    });

    QwenKey.text = _box.read('QwenKey') ?? '';
    OpenAIKey.text = _box.read('OpenAIKey') ?? '';
    ZhipuKey.text = _box.read('ZhipuKey') ?? '';
    DSKey.text = _box.read('DSKey') ?? '';
  }

  // Key持久化
  void keySaved() {
    _box.write('QwenKey', QwenKey.text);
    _box.write('OpenAIKey', OpenAIKey.text);
    _box.write('ZhipuKey', ZhipuKey.text);
    _box.write('DSKey', DSKey.text);
    showNotification(FlutterI18n.translate(context, "saved"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Align(alignment: Alignment.centerLeft, child: Text("APIKey")),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // 取消焦点，收起键盘
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding:
              const EdgeInsets.only(top: 5, bottom: 12, left: 12, right: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  obscureText: true,
                  controller: DSKey,
                  decoration: const InputDecoration(
                      labelText: "Deepseek APIKey",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(
                            Uri.parse('https://platform.deepseek.com/sign_in'));
                      },
                      child: Text(
                        FlutterI18n.translate(context, "howtogetit"),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: OpenAIKey,
                  decoration: const InputDecoration(
                      labelText: "OpenAI APIKey", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            'https://platform.openai.com/docs/quickstart?language-preference=curl&quickstart-example'));
                      },
                      child: Text(
                        FlutterI18n.translate(context, "howtogetit"),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: ZhipuKey,
                  decoration: const InputDecoration(
                      labelText: "ChatGLM APIKey",
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            'https://bigmodel.cn/dev/api/http-call/http-auth'));
                      },
                      child: Text(
                        FlutterI18n.translate(context, "howtogetit"),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  controller: QwenKey,
                  decoration: const InputDecoration(
                      labelText: "Qwen APIKey", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            'https://help.aliyun.com/zh/model-studio/getting-started/first-api-call-to-qwen'));
                      },
                      child: Text(
                        FlutterI18n.translate(context, "howtogetit"),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    )),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    keySaved();
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.primary),
                    foregroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.onPrimary),
                  ),
                  child: Text(FlutterI18n.translate(context, "save")),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
