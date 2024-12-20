import 'package:chatwhiz/mobile/import.dart';

AboutDialog buildAboutDialog() {
  return AboutDialog(
    applicationVersion: AppConstants.appVersion,
    applicationName: 'ChatWhiz',
    applicationLegalese: "Copyright© 2024 Lance Huang",
  );
}
