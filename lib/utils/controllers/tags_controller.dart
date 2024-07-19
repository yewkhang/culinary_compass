import 'package:get/get.dart';

class TagsController extends GetxController {
  var selectedTags = List<String>.empty(growable: true).obs;
  var selectedFriendsNames = List<String>.empty(growable: true).obs;
}