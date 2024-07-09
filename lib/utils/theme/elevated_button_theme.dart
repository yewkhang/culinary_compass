import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class CCElevatedTextButtonTheme {
  CCElevatedTextButtonTheme._();

  static ButtonStyle lightInputButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: CCColors.primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
}

class CCElevatedIconButtonTheme {
  CCElevatedIconButtonTheme._();

  static ButtonStyle lightInputButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: CCColors.primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)));
}

class CCCircularElevatedButtonTheme {
  CCCircularElevatedButtonTheme._();

  static ButtonStyle lightInputButtonStyle = ElevatedButton.styleFrom(
      shape: const CircleBorder(),
      elevation: 0,
      foregroundColor: CCColors.primaryColor,
      backgroundColor: Colors.grey.shade100);
}
