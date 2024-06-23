import 'package:flutter/material.dart';

// Decoration for Textboxes
// note: Color.fromRGBO() is used as constant value
// input hintText by chaining with .copyWith() in other files
const textInputDecoration = InputDecoration(
  fillColor: Color.fromRGBO(238, 238, 238, 1),
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color.fromRGBO(224, 224, 224, 1), width: 2.0)
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.black, width: 2.0)
  )
);

class DefaultTextFormField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;

  const DefaultTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      //initialValue: email,
      decoration: textInputDecoration.copyWith(hintText: hintText),
      // returns null --> means is valid
      // can validate more
      validator: (typedEmail) => typedEmail!.isEmpty ? "Enter an email" : null,
      onChanged: (typedEmail) {
      //  setState(() => email = typedEmail);
      },
    );
  }
}

class OtherSignInMethods extends StatelessWidget {

  final String imagePath;
  final Function()? onTap;

  const OtherSignInMethods({
    super.key,
    required this.imagePath,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200]
        ),
        height: 70,
        child: Image.asset(
          imagePath,
        ),
      ),
    );
  }
}