import 'dart:convert';
import 'package:culinary_compass/utils/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LocationController extends GetxController {
  TextEditingController locationSearch = TextEditingController();

  dynamic data;
  final uuid = const Uuid();
  String sessionToken = '123';

  RxBool isLoading = false.obs;
  RxString inputAddress = ''.obs;
  RxString selectedAddress = ''.obs;

  @override
  void onInit() {
    locationSearch.addListener(() {
      autoCompleteAPI();
    });
    super.onInit();
  }

  Future<void> autoCompleteAPI() async {
    isLoading.value = true;
    if (sessionToken == '123') {
      sessionToken = uuid.v4();
    }

    final request = '$MAPS_URL?input=${locationSearch.text}&sessionToken=$sessionToken&key=$MAPS_API&types=food&language=en';
    final response = await http.get(Uri.parse(request));

    if (response.statusCode == 200) {
      isLoading.value = false;
      final result = jsonDecode(response.body.toString());
      if (result['status'] == 'OK') {
        data = result['predictions'];
      }
    } else {
      throw Exception('Failed to load location data');
    }
  }

  bool get showAutoCompleteList {
    return selectedAddress.value.isNotEmpty && data != [];
  }
}