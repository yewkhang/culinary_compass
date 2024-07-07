import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/pages/logging_page.dart';
import 'package:culinary_compass/pages/viewlogs_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/models/tags_model.dart';

class SearchFieldController extends GetxController {
  static SearchFieldController get instance => Get.find();
  final userRepository = Get.put(UserRepository());
  var query = ''.obs;

  // --- FILTERING VARIABLES --- //
  // for filtering page to track selected tags
  var selectedCuisineFilters = List<String>.empty(growable: true).obs;
  // for yourlogs page to update ListView
  var finalCuisineFilters = List<String>.empty(growable: true).obs;
  // for filters_page to reference, can be made to store in Firestore
  var cuisineFilters = TagsModel.tags;

  // --- METHODS --- //

  Widget buildSearchResults(
      String search, List<String> cuisineFiltersFromUser, bool fromHomePage) {
    return StreamBuilder<QuerySnapshot>(
      stream: fromHomePage ? Stream.fromFuture(userRepository.fetchAllFriendLogs()) : userRepository.fetchAllUserLogs(),
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? const Center(
                // Retrieving from Firestore
                child: CircularProgressIndicator(
                  color: CCColors.primaryColor,
                ),
              )
            : ListView.builder(
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
                  if (data['Name'].toString().toLowerCase().contains(search) &&
                      // returns true and displays search only results if isEmpty,
                      // else also displays filter results
                      (cuisineFiltersFromUser.isEmpty ||
                          cuisineFiltersFromUser
                              .any((e) => data['Tags'].toList().contains(e)))) {
                    return Slidable(
                      // Slide to left to delete log
                      // if fromHomePage, dont allow sliding
                      endActionPane: fromHomePage ? null : ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) => Get.defaultDialog(
                                      title: 'Delete Log',
                                      middleText:
                                          'Are you sure you want to delete this log?',
                                      confirm: ElevatedButton(
                                          onPressed: () {
                                            userRepository.deleteUserLog(
                                                docID, data['Picture']);
                                            Get.back();
                                          },
                                          child: const Text('Delete Log')),
                                      cancel: ElevatedButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel')),
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
                        subtitle: Text(data['Location']),
                        trailing: Text(
                          '${data['Rating']}⭐',
                          style: const TextStyle(fontSize: 16),
                        ),
                        onTap: () {
                          // Redirect to edit log
                          Get.to(
                              fromHomePage ? ViewlogsPage(document: data) : LoggingPage(
                                fromYourLogsPage: true,
                                docID: docID,
                                originalPictureURL: data['Picture'],
                                name: data['Name'],
                                location: data['Location'],
                                description: data['Description'],
                                rating: data['Rating'],
                                tags: data['Tags'].whereType<String>().toList(),
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
      },
    );
  }
}
