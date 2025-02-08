import 'package:chatwhiz/desktop/import.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final GetStorage _box = GetStorage();
  final TextEditingController ipCtr = TextEditingController();
  final TextEditingController portCtr = TextEditingController();

  bool selectedCollect = true;
  bool selectedAutoCheckUpdate = true;
  bool selectedProxy = false;
  int selectedProxyType = 0;

  @override
  void initState() {
    super.initState();
    selectedAutoCheckUpdate = _box.read('autoCheckUpdate') ?? true;
    selectedProxy = _box.read('proxy') ?? false;

    // 加载代理设置
    var proxyData = _box.read('proxySettings');
    if (proxyData != null) {
      var proxySettings = ProxySettings.fromMap(proxyData);
      ipCtr.text = proxySettings.ip;
      portCtr.text = proxySettings.port.toString();
      selectedProxyType = proxySettings.protocol == 'Http' ? 0 : 1;
    }
  }

  // 保存代理设置
  void saveProxySettings() {
    if (!selectedProxy) return;

    var proxySettings = ProxySettings(
      protocol: selectedProxyType == 0 ? 'Http' : 'Socks5',
      ip: ipCtr.text,
      port: int.tryParse(portCtr.text) ?? 0,
    );

    // 保存到 GetStorage
    _box.write('proxySettings', proxySettings.toMap());
    showProxySaved(context);
  }

  // 保存代理设置对话框
  void showProxySaved(BuildContext context) async {
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

  // 代理设置
  void onProxy(bool? value) {
    if (value == null) return;
    setState(() {
      selectedProxy = value;
      _box.write('proxy', value);
    });
  }

  // 自动检查更新设置
  void onAutoCheckUpdate(bool? value) {
    if (value == null) return;
    setState(() {
      selectedAutoCheckUpdate = value;
      _box.write('autoCheckUpdate', value);
    });
  }

  // 自动检查更新关闭对话框
  void showAutoCheckUpdateDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text('关闭自动检查更新'),
        content: const Text(
          '您需要自行前往官方仓库才能获取最新的版本情况，您确定关闭吗？',
        ),
        actions: [
          Button(
            child: const Text('是'),
            onPressed: () {
              onAutoCheckUpdate(false);
              Navigator.pop(context);
            },
          ),
          FilledButton(
            child: const Text('否'),
            onPressed: () {
              onAutoCheckUpdate(true);
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
            "设置",
            style: FluentTheme.of(context)
                .typography
                .title
                ?.copyWith(fontSize: 38),
          ),
        ),
      ),
      children: [
        const SizedBox(height: 30),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              content: const Text("自动检查更新"),
              checked: selectedAutoCheckUpdate,
              onChanged: (v) {
                if (v == false) {
                  showAutoCheckUpdateDialog(context);
                } else {
                  onAutoCheckUpdate(v);
                }
              },
            ),
            const SizedBox(height: 10),
            Checkbox(
              content: const Text("启用代理设置"),
              checked: selectedProxy,
              onChanged: (v) {
                onProxy(v);
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(2, (index) {
                return RadioButton(
                    content:
                        index == 0 ? const Text("Http") : const Text("Socks5"),
                    checked: selectedProxyType == index,
                    onChanged: selectedProxy
                        ? (checked) {
                            if (checked) {
                              setState(() {
                                selectedProxyType = index;
                              });
                            }
                          }
                        : null);
              }),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: '代理服务器:',
              child: TextBox(
                controller: ipCtr,
                placeholder: '127.0.0.1',
                expands: false,
                enabled: selectedProxy,
              ),
            ),
            const SizedBox(height: 10),
            InfoLabel(
              label: '服务器端口:',
              child: TextBox(
                controller: portCtr,
                placeholder: '7890',
                expands: false,
                enabled: selectedProxy,
              ),
            ),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: selectedProxy
                  ? () {
                      saveProxySettings();
                    }
                  : null,
              child: const Text("保存并应用"),
            )
          ],
        ),
      ],
    );
  }
}
