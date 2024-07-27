import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/pages/logging_page.dart';
import 'package:culinary_compass/pages/viewlogs_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/grouprecs_controller.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/models/tags_model.dart';

class SearchFieldController extends GetxController {
  static SearchFieldController get instance => Get.find();
  final GrouprecsController grouprecsController =
      Get.put(GrouprecsController());
  final userRepository = Get.put(UserRepository());
  final profileController = Get.put(ProfileController());
  var query = ''.obs;

  // --- FILTERING VARIABLES --- //
  // for filtering page to track selected tags
  var selectedCuisineFilters = List<String>.empty(growable: true).obs;
  // for yourlogs page to update ListView
  var finalCuisineFilters = List<String>.empty(growable: true).obs;
  // for filters_page to reference, can be made to store in Firestore
  var cuisineFilters = TagsModel.tags;

  // --- METHODS --- //
  // For recommendations page, search and filter JSON data
  // List<dynamic> data contains all suggestions
  List<dynamic> searchAndFilterRecommendationsData(List<dynamic> data) {
    List<dynamic> searchAndFilteredList = data
        // for each item in the data
        .where((item) =>
            // check whether user is searching for location
            (item['Location']
                    .toString()
                    .toLowerCase()
                    .contains(query.value.toLowerCase()) ||
                // OR check whether user is searching for dish name
                grouprecsController
                    .consolidateDishNames(item)
                    .toString()
                    .toLowerCase()
                    .contains(query.value.toLowerCase())) &&
            // show results that match user's filters
            (finalCuisineFilters.isEmpty ||
                finalCuisineFilters.any((e) =>
                    grouprecsController.consolidateTags(item).contains(e))))
        .toList();
    return searchAndFilteredList;
  }

  Widget buildSearchResults(String search, List<String> cuisineFiltersFromUser,
      bool fromHomePage, String friendUID) {
    return StreamBuilder<QuerySnapshot>(
      stream: fromHomePage
          ? friendUID.isNotEmpty
              ? (userRepository.fetchSpecificFriendLogs(friendUID))
              :
              // copy user's friendUID list to prevent from constantly adding to the list
              userRepository.fetchAllFriendLogs(
                  List.from(profileController.user.value.friendsUID)
                    ..add(profileController.user.value.uid))
          : userRepository.fetchAllUserLogs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            // Retrieving from Firestore
            child: CircularProgressIndicator(
              color: CCColors.primaryColor,
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'No logs have been added yet!',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                // ID of each document
                String docID = snapshot.data!.docs[index].id;
                // data contains ALL logs from user
                var data =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                // Show results that match search AND filters
                if (((data['Name'].toString() + data['Location'].toString())
                        .toLowerCase()
                        .contains(search)) && // search for location or name
                    // returns true and displays search only results if isEmpty,
                    // else also displays filter results
                    (cuisineFiltersFromUser.isEmpty ||
                        cuisineFiltersFromUser
                            .any((e) => data['Tags'].toList().contains(e)))) {
                  return Slidable(
                    // Slide to left to delete log
                    // if fromHomePage, dont allow sliding
                    endActionPane: fromHomePage
                        ? null
                        : ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.25,
                            children: [
                                SlidableAction(
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    onPressed: (context) => Get.defaultDialog(
                                          backgroundColor: Colors.white,
                                          title: 'Delete Log',
                                          middleText:
                                              'Are you sure you want to delete this log?',
                                          confirm: ElevatedButton(
                                              style: CCElevatedTextButtonTheme
                                                  .lightInputButtonStyle,
                                              onPressed: () {
                                                userRepository.deleteUserLog(
                                                    docID, data['Picture']);
                                                Get.back();
                                              },
                                              child: const Text(
                                                'Delete Log',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                          cancel: ElevatedButton(
                                              style: CCElevatedTextButtonTheme
                                                  .unselectedButtonStyle,
                                              onPressed: () => Get.back(),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                        ))
                              ]),
                    child: ListTile(
                      leading: SizedBox(
                          height: 80,
                          width: 80,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: data.containsKey('Picture')
                                  ? Image.network(
                                      data['Picture'],
                                      fit: BoxFit.cover,
                                    )
                                  : const Text('No picture!'))),
                      title: Text(
                        data['Name'],
                        style: const TextStyle(fontSize: 18),
                      ),
                      subtitle: Text(
                        data['Location'],
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        '${data['Rating']}⭐',
                        style: const TextStyle(fontSize: 16),
                      ),
                      onTap: () {
                        // Redirect to edit log
                        Get.to(
                            fromHomePage
                                ? ViewlogsPage(document: data)
                                : LoggingPage(
                                    fromYourLogsPage: true,
                                    docID: docID,
                                    originalPictureURL: data['Picture'],
                                    name: data['Name'],
                                    location: data['Location'],
                                    description: data['Description'],
                                    rating: data['Rating'],
                                    tags: data['Tags']
                                        .whereType<String>()
                                        .toList(),
                                  ),
                            transition: Transition.rightToLeftWithFade);
                      },
                    ),
                  );
                } else {
                  // Hide results that do not match the search
                  return const SizedBox();
                }
              });
        }
      },
    );
  }
}
