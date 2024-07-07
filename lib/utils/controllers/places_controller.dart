import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlacesController extends GetxController{
  static PlacesController get instance => Get.find();

  TextEditingController nameTextField = TextEditingController();
  TextEditingController descriptionTextField = TextEditingController();
}