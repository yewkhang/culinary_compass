import 'dart:convert';
import 'package:culinary_compass/user_repository.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GrouprecsController extends GetxController {
  List<dynamic> data = [];
  var jsonInputData = '';
  final userRepository = Get.put(UserRepository());

  Future<void> herokuAPI(List<String> membersUID) async {
    String jsonData = await userRepository.getFirestoreDataAsJson(membersUID);
    var url = //url includes the method name in python
        Uri.parse(
            'https://culinary-compass-706a522f797f.herokuapp.com/process_data');
    var response = await http.post(url,
        headers: {'Content-Type': 'application/json'}, body: jsonData);
    if (response.statusCode == 200) {
      data = jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      print('heroku error 404');
    } else {
      print('error' + response.statusCode.toString());
    }
  }

  String consolidateDishNames(dynamic selectedData) {
    String consolidatedDishNames = '';
    for (int i = 0; i < selectedData['dishes'].length; i++) {
      if (i == selectedData['dishes'].length - 1) {
        consolidatedDishNames =
            consolidatedDishNames + selectedData['dishes'][i]['Name'];
      } else {
        // add comma to end of dish if there are more dishes with the same location
        consolidatedDishNames =
            "${consolidatedDishNames + selectedData['dishes'][i]['Name']}, ";
      }
    }
    return consolidatedDishNames;
  }
}
