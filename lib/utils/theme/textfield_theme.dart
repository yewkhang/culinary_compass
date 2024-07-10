import "package:culinary_compass/utils/constants/colors.dart";
import "package:culinary_compass/utils/constants/sizes.dart";
import "package:flutter/material.dart";

class CCTextFieldTheme {
  CCTextFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
      labelStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.black),
      hintStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.black),
      errorStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.black),
      floatingLabelStyle:
          const TextStyle().copyWith(color: Colors.black.withOpacity(0.8)),
      border: const OutlineInputBorder().copyWith(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: Colors.amber)),
      focusedBorder: const OutlineInputBorder().copyWith(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: Colors.amber)));

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
      labelStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
      hintStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
      errorStyle: const TextStyle().copyWith(fontSize: 14, color: Colors.white),
      floatingLabelStyle:
          const TextStyle().copyWith(color: Colors.white.withOpacity(0.8)),
      border: const OutlineInputBorder().copyWith(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: Colors.amber)),
      focusedBorder: const OutlineInputBorder().copyWith(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(width: 1, color: Colors.amber)));
}

InputDecoration textFieldInputDecoration({
  required String hintText,
  required IconData prefixIcon,
}) {
  return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(
        prefixIcon,
        color: CCColors.primaryColor,
      ),
      contentPadding: const EdgeInsets.all(CCSizes.spaceBtwItems),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide:
              const BorderSide(color: CCColors.primaryColor, width: 2)));
}
