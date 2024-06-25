import 'package:get/get.dart';
import 'package:culinary_compass/models/tags_model.dart';

class FilterController extends GetxController {
  var selectedCuisineFilters = List<String>.empty(growable: true).obs;
  var cuisineFilters = TagsModel.tags;
}