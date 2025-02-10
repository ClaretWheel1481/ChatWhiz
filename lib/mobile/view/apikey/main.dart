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

  @override
  void initState() {
    QwenKey.text = _box.read('QwenKey') ?? '';
    OpenAIKey.text = _box.read('OpenAIKey') ?? '';
    ZhipuKey.text = _box.read('ZhipuKey') ?? '';
    DSKey.text = _box.read('DSKey') ?? '';

    super.initState();
  }

  // Key持久化
  void keySaved() {
    _box.write('QwenKey', QwenKey.text);
    _box.write('OpenAIKey', OpenAIKey.text);
    _box.write('ZhipuKey', ZhipuKey.text);
    _box.write('DSKey', DSKey.text);
    showNotification("您的APIKey很安全地保存于本地中。");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Align(
              alignment: Alignment.centerLeft, child: Text("APIKey")),
        ),
        body: Padding(
          padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
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
                      child: const Text(
                        "如何获取？",
                        style: TextStyle(
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
                      child: const Text(
                        "如何获取？",
                        style: TextStyle(
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
                      labelText: "智谱 APIKey", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            'https://bigmodel.cn/dev/api/http-call/http-auth'));
                      },
                      child: const Text(
                        "如何获取？",
                        style: TextStyle(
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
                      labelText: "千问 APIKey", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 5),
                Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await launchUrl(Uri.parse(
                            'https://help.aliyun.com/zh/model-studio/getting-started/first-api-call-to-qwen'));
                      },
                      child: const Text(
                        "如何获取？",
                        style: TextStyle(
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
                  child: const Text("保存"),
                ),
              ],
            ),
          ),
        ));
  }
}
