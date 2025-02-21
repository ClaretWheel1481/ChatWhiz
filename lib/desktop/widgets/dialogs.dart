import 'package:chatwhiz/desktop/import.dart';

// 双按钮对话框
void show2ButtonsDialog(
    BuildContext context, String title, content, Function()? yes, no) async {
  await showDialog<void>(
    context: context,
    builder: (context) => ContentDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        Button(
          onPressed: yes,
          child: const Text('是'),
        ),
        FilledButton(
          onPressed: no,
          child: const Text('否'),
        ),
      ],
    ),
  );
}

// 单按钮对话框
void show1ButtonDialog(
    BuildContext context, String title, Function()? ok) async {
  await showDialog<void>(
    context: context,
    builder: (context) => ContentDialog(
      title: Text(title),
      actions: [
        FilledButton(
          onPressed: ok,
          child: const Text('好'),
        ),
      ],
    ),
  );
}

// 底部消息窗口
void showNotification(BuildContext context, String title, content,
    InfoBarSeverity severity) async {
  await displayInfoBar(context, builder: (context, close) {
    return InfoBar(
      title: Text(title),
      content: Text(content),
      action: IconButton(
        icon: const Icon(FluentIcons.clear),
        onPressed: close,
      ),
      severity: severity,
    );
  });
}
