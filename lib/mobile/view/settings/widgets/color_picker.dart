import 'package:chatwhiz/mobile/notify.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:get/get.dart';

// 颜色选择对话框
void showColorPickerDialog(
    BuildContext context, Color currentColor, Function(Color) onColorSelected) {
  Color pickerColor = currentColor;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("选取一个颜色"),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pickerColor,
            onColorChanged: (color) => pickerColor = color,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("取消"),
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
            child: const Text("确认"),
            onPressed: () {
              onColorSelected(pickerColor);
              Get.back();
              showNotification("颜色已保存，重启后生效。");
            },
          ),
        ],
      );
    },
  );
}
