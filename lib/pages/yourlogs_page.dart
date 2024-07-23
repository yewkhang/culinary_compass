import 'package:culinary_compass/pages/filters_page.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class YourlogsPage extends StatelessWidget {
  final bool fromHomePage;
  final String friendUID;
  const YourlogsPage({super.key, this.fromHomePage = false, this.friendUID = ''});

  @override
  Widget build(BuildContext context) {
    final searchController = Get.put(SearchFieldController());
    // initial values 
    searchController.query.value = '';
    searchController.finalCuisineFilters.clear();
    searchController.selectedCuisineFilters.clear();

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
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              autofocus: fromHomePage,
              onChanged: (value) {
                searchController.query.value = value;
              },
              decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  focusColor: Colors.transparent,
                  border: const OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: fromHomePage ? 'Search friend logs' : 'Search logs',
                  contentPadding: const EdgeInsets.symmetric(
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
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          // rebuild widget based on changes in search query and finalCuisineFilters
          child: Obx(
            () =>
                searchController // add a toList() to access the value List<String> instead of RxList<String>
                    .buildSearchResults(searchController.query.value,
                        searchController.finalCuisineFilters.toList(), fromHomePage, friendUID),
          ),
        ));
  }
}
