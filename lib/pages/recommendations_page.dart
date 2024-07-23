import 'package:culinary_compass/pages/filters_page.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/grouprecs_controller.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/controllers/search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecommendationsPage extends StatelessWidget {
  final GrouprecsController grouprecsController =
      Get.put(GrouprecsController());
  final GroupsController groupsController = Get.put(GroupsController());
  final SearchFieldController searchController =
      Get.put(SearchFieldController());
  RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Show filter bottom sheet
    void showFilters() {
      showModalBottomSheet(
          context: context,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          builder: (context) {
            return FiltersPage();
          });
    }

    return PopScope(
      onPopInvoked: (didPop) => didPop ? searchController.query.value = '' : null,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onChanged: (value) {
                searchController.query.value = value;
              },
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  focusColor: Colors.transparent,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Suggest a place',
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
          child: Obx(
            () // rebuild ListView everytime list changes
                =>
                ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: searchController
                            .searchAndFilterRecommendationsData(
                                grouprecsController.data)
                            .length,
                        itemBuilder: (context, index) {
                          // get data from API call that matches search and filters
                          var tileData =
                              searchController.searchAndFilterRecommendationsData(
                                  grouprecsController.data)[index];
                          // gather all the dishes that share the same location into a comma separated String
                          String consolidatedDishNames =
                              grouprecsController.consolidateDishNames(tileData);
                          return ListTile(
                            title: Text(tileData['Location']),
                            subtitle: Text(consolidatedDishNames),
                            // toStringAsFixed to round numbers to 2dp
                            trailing: Text(
                              '${tileData['average_rating'].toStringAsFixed(2)}⭐',
                              style: const TextStyle(fontSize: 16),
                            ),
                            onTap: () {
                              // user selects the choice they want to suggest
                              String location = tileData['Location'];
                              String averageRating =
                                  tileData['average_rating'].toStringAsFixed(2);
                              String suggestionText =
                                  "Let's eat at $location! \n\nFood:\n$consolidatedDishNames \n\nAverage Rating: $averageRating⭐";
                              // assign suggestion text to chat Textfield
                              groupsController.chatTextController.text =
                                  suggestionText;
                              // clear search field text
                              searchController.query.value = '';
                              // go back to groups page
                              Get.back();
                            },
                          );
                        }),
          ),
        ),
      ),
    );
  }
}
