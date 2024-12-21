import 'package:chatwhiz/pc/import.dart';

List<NavigationPaneItem> pages = [
  PaneItem(
      icon: const Icon(FluentIcons.home),
      body: const Home(),
      title: const Text('主页')),
  PaneItem(
      icon: const Icon(FluentIcons.settings),
      body: const Settings(),
      title: const Text('设置')),
];

class PCHomePage extends StatefulWidget {
  const PCHomePage({super.key});

  @override
  State<PCHomePage> createState() => _PCHomePageState();
}

class _PCHomePageState extends State<PCHomePage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        // TODO: 图标待添加
        leading: SizedBox(),
        title: const Text(
          'ChatWhiz',
        ),
        actions: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: MoveWindow(),
            ),
            SizedBox(
              width: 50,
              height: 60,
              child: MinimizeWindowButton(),
            ),
            SizedBox(
              width: 50,
              height: 60,
              child: MaximizeWindowButton(),
            ),
            SizedBox(
              width: 50,
              height: 60,
              child: CloseWindowButton(),
            ),
          ],
        ),
      ),
      pane: NavigationPane(
          size: const NavigationPaneSize(openMaxWidth: 200),
          items: pages,
          footerItems: [
            PaneItemSeparator(),
            PaneItem(
                icon: const Icon(FluentIcons.info),
                body: const About(),
                title: const Text('关于')),
          ],
          selected: selectedIndex,
          onChanged: (index) => setState(() => selectedIndex = index),
          displayMode: PaneDisplayMode.compact),
    );
  }
}
