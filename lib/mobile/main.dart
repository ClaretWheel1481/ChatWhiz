import 'import.dart';
import 'package:dio/dio.dart' as d;

class MobileHomePage extends StatefulWidget {
  const MobileHomePage({super.key});

  @override
  State<MobileHomePage> createState() => _MobileHomePageState();
}

class _MobileHomePageState extends State<MobileHomePage> {
  int _position = 0;

  final Map<String, IconData> iconsMap = {
    //底栏图标
    "主页": Icons.home, "APIKey": Icons.key,
    "设置": Icons.settings,
  };

  final List<Widget> _pages = [
    const HomePage(),
    const ApiKey(),
    const Settings()
  ];

  // 测试网络以便在iOS应用启动时获取权限
  void testInternet() async {
    try {
      d.Response resp = await d.Dio().get("https://www.baidu.com");
      debugPrint(resp.statusMessage);
    } catch (e) {
      showNotification("网络连接失败，请检查您的权限或设置！");
    }
  }

  @override
  void initState() {
    super.initState();
    testInternet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) {
          // 使用淡入淡出的过渡动画
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: _pages[_position],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          onTap: (position) => setState(() => _position = position),
          currentIndex: _position,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          items: iconsMap.keys
              .map((key) => BottomNavigationBarItem(
                    label: key,
                    icon: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18.0, vertical: 6),
                      decoration: BoxDecoration(
                        color: _position == iconsMap.keys.toList().indexOf(key)
                            ? Theme.of(context).colorScheme.secondaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(iconsMap[key]),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.onSecondaryContainer,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
