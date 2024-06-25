import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:culinary_compass/models/tags_model.dart';

class SearchFieldController extends GetxController {
  static SearchFieldController get instance => Get.find();
  final userRepository = Get.put(UserRepository());
  var query = ''.obs;

  // --- Filtering --- //
  var selectedCuisineFilters = List<String>.empty(growable: true).obs; // for filtering page
  var finalCuisineFilters = List<String>.empty(growable: true).obs; // for yourlogs page to update ListView
  var cuisineFilters = TagsModel.tags;

  // retrieve user data from Firestore
  Stream<QuerySnapshot> getResults() {
    return Stream.fromFuture(userRepository.fetchAllUserLogs());
  }

  Widget buildSearchResults(String search, List<String> cuisineFilters) {
    return StreamBuilder<QuerySnapshot>(
      stream: Stream.fromFuture(userRepository.fetchAllUserLogs()),
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? const Center(
                child: CircularProgressIndicator(
                  color: CCColors.primaryColor,
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // data contains ALL logs from user
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  // Filter results
                  // Show results that match search
                  if (data['Name'].toString().toLowerCase().contains(search) &&
                          cuisineFilters.isEmpty
                      ? true // show all entries if filter is empty
                      : cuisineFilters
                          .any((e) => data['Tags'].toList().contains(e))) {
                    return ListTile(
                      leading: Container(
                          child: data.containsKey('Picture')
                              ? Image.network(data['Picture'])
                              : const Text('No picture!')),
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
                        // Redirect to edit/delete log
                      },
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
