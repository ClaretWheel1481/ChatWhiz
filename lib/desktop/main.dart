import 'package:chatwhiz/desktop/import.dart';
import 'package:chatwhiz/desktop/view/apikey/main.dart';

List<NavigationPaneItem> routers = [
  PaneItem(
      icon: const Icon(FluentIcons.home),
      body: const Home(),
      title: const Text('主页')),
  PaneItem(
      icon: const Icon(FluentIcons.azure_key_vault),
      body: const Apikey(),
      title: const Text('API Key')),
  PaneItem(
      icon: const Icon(FluentIcons.chat),
      body: const Chat(),
      title: const Text('对话')),
  PaneItem(
      icon: const Icon(FluentIcons.settings),
      body: const Settings(),
      title: const Text('设置')),
];

class DesktopHomePage extends StatefulWidget {
  const DesktopHomePage({super.key});

  @override
  State<DesktopHomePage> createState() => _DesktopHomePageState();
}

class _DesktopHomePageState extends State<DesktopHomePage> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        leading: const Image(
          image: AssetImage("public/Logo.png"),
          width: 25,
          height: 25,
        ),
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
          items: routers,
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
