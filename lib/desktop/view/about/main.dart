import 'package:chatwhiz/desktop/import.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage.scrollable(
        header: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "关于",
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
              Text("ChatWhiz ${AppConstants.appVersion}",
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 25),
              HyperlinkButton(
                  onPressed: () async {
                    await launchUrl(Uri.parse(
                        'https://github.com/ClaretWheel1481/ChatWhiz'));
                  },
                  child: const Text("Repository"))
            ],
          ),
        ]);
  }
}
