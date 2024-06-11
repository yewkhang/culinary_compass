import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TextfieldControllers extends GetxController{
  static TextfieldControllers get instance => Get.find();

  TextEditingController nameTextField = TextEditingController();
  TextEditingController descriptionTextField = TextEditingController();
}
