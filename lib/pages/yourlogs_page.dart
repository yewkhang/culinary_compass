import 'package:culinary_compass/pages/filters_page.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/filter_controller.dart';
import 'package:culinary_compass/utils/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YourlogsPage extends StatelessWidget {
  const YourlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(SearchFieldController());
    final filtersController = Get.put(FilterController());

    void showFilters() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: FiltersPage(),
            );
          });
    }

    return Scaffold(
        appBar: AppBar(
          title: Card(
            child: TextField(
              onChanged: (value) {
                searchController.query.value = value;
              },
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                focusColor: Colors.transparent,
                hintText: 'Search logs',
              ),
            ),
          ),
          actions: [
            IconButton( // can use Get.to()
                onPressed: () => showFilters(), icon: const Icon(Icons.filter_alt))
          ],
          backgroundColor: CCColors.primaryColor,
        ),
        body: SingleChildScrollView(
          child: Obx(
            () => searchController
                .buildSearchResults(searchController.query.value, filtersController.selectedCuisineFilters),
          ),
        ));
  }
}
