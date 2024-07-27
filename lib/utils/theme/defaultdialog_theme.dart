import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CCDefaultDialogTheme {
  CCDefaultDialogTheme._();

  static defaultGetxDialog(String titleText, String middleText, String confirmText, void Function() onPressed) {
    return Get.defaultDialog(
      backgroundColor: Colors.white,
      title: titleText,
      middleText: middleText,
      confirm: ElevatedButton(
        style: CCElevatedTextButtonTheme.lightInputButtonStyle,
        onPressed: onPressed,
        child: Text(
          confirmText,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      cancel: ElevatedButton(
        style: CCElevatedTextButtonTheme.unselectedButtonStyle,
        onPressed: () => Get.back(),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}
