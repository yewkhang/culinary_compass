import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    SearchFieldController filtersController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter by:"),
        backgroundColor: CCColors.primaryColor,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // --- cuisine title + clear tags button --- //
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              'Cuisine:',
              style: TextStyle(fontSize: 20),
            ),
            TextButton(
                onPressed: () =>
                    filtersController.selectedCuisineFilters.clear(),
                child: const Text(
                  'Clear Tags',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ))
          ]),
          // --- horizontal list of tags --- //
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filtersController
                  .cuisineFilters // contains all cuisines
                  .map((element) => Obx( // rebuild everytime a tag is selected to show state
                        () => Padding(
                          // padding between tags
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: FilterChip(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(2),
                            selectedColor: CCColors.primaryColor,
                              label: Text(element),
                              // boolean of whether a tag is selected
                              selected: filtersController.selectedCuisineFilters
                                  .contains(element),
                              onSelected: (selected) {
                                // determine whether to remove or add tags
                                if (selected) {
                                  filtersController.selectedCuisineFilters
                                      .add(element);
                                } else {
                                  filtersController.selectedCuisineFilters
                                      .remove(element);
                                }
                              }),
                        ),
                      ))
                  .toList(),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                // remove all prev cuisine tags
                filtersController.finalCuisineFilters.clear();
                // add all selected tags for search page to rebuild search results
                filtersController.finalCuisineFilters
                    .addAll(filtersController.selectedCuisineFilters);
                Get.back(); // back to search page
              },
              child: const Text('Done'))
        ],
      ),
    );
  }
}
