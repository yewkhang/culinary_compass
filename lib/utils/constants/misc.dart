import 'package:flutter/material.dart';

// for Textboxes
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