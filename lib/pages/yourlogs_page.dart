import 'package:culinary_compass/pages/filters_page.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YourlogsPage extends StatelessWidget {
  const YourlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(SearchFieldController());

    // Show filter bottom sheet
    void showFilters() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return FiltersPage();
          });
    }

    return Scaffold(
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TextField(
              onChanged: (value) {
                searchController.query.value = value;
              },
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  focusColor: Colors.transparent,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Search logs',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: BorderSide.strokeAlignCenter)),
            ),
          ),
          actions: [
            IconButton(
                // can use Get.to()
                onPressed: () => showFilters(),
                icon: const Icon(Icons.filter_alt))
          ],
          backgroundColor: CCColors.primaryColor,
        ),
        body: SingleChildScrollView(
          // rebuild widget based on changes in search query and finalCuisineFilters
          child: Obx(
            () =>
                searchController // add a toList() to access the value List<String> instead of RxList<String>
                    .buildSearchResults(searchController.query.value,
                        searchController.finalCuisineFilters.toList()),
          ),
        ));
  }
}
