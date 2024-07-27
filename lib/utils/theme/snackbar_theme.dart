import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CCSnackBarTheme {
  CCSnackBarTheme._();

  static SnackbarController defaultSuccessSnackBar(String titleText) {
    return Get.snackbar('', '',
        titleText: Text(
          titleText,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        messageText: const SizedBox(),
        icon: const Icon(
          Icons.check_circle_outline_outlined,
          color: Colors.white,
        ),
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(milliseconds: 2500));
  }

  static SnackbarController defaultFailureSnackBar(String titleText) {
    return Get.snackbar('', '',
        titleText: Text(
          titleText,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        messageText: const SizedBox(),
        icon: const Icon(
          Icons.cancel_outlined,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        duration: const Duration(milliseconds: 2500));
  }
}
