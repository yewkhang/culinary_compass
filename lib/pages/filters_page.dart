import 'package:culinary_compass/utils/controllers/filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FiltersPage extends StatelessWidget {
  const FiltersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final filtersController = Get.put(FilterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter by:"),
      ),
      body: Column(
        children: [
          const Text('Cuisine:'),
          Container(
            margin: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: filtersController.cuisineFilters
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
          ElevatedButton(onPressed: () {Navigator.pop(context);}, child: const Text('Done'))
        ],
      ),
    );
  }
}
