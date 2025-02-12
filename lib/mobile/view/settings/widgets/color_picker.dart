import 'package:chatwhiz/mobile/import.dart';

// 颜色选择对话框
void showColorPickerDialog(
    BuildContext context, Color currentColor, Function(Color) onColorSelected) {
  Color pickerColor = currentColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(FlutterI18n.translate(context, "custom_color")),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(FlutterI18n.translate(context, "cancel")),
            onPressed: () {
              Get.back();
            },
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor:
                  WidgetStatePropertyAll(Theme.of(context).colorScheme.primary),
              foregroundColor: WidgetStatePropertyAll(
                  Theme.of(context).colorScheme.onPrimary),
            ),
            child: Text(FlutterI18n.translate(context, "save")),
            onPressed: () {
              onColorSelected(pickerColor);
              Get.back();
              showNotification(
                  FlutterI18n.translate(context, "effective_after_reboot"));
            },
          ),
        ],
      );
    },
  );
}
