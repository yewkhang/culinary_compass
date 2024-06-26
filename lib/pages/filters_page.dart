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
      ),
      body: Column(
        children: [
          const Text('Cuisine:', style: TextStyle(fontSize: 16),),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: filtersController
                  .cuisineFilters // contains all cuisines
                  .map((element) => Obx(
                        () => FilterChip(
                            label: Text(element),
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
                      ))
                  .toList(),
            ),
          ),
          ElevatedButton(
              onPressed: () {
                filtersController.finalCuisineFilters.clear();
                filtersController.finalCuisineFilters.addAll(filtersController.selectedCuisineFilters);
                Get.back();
              },
              child: const Text('Done'))
        ],
      ),
    );
  }
}
