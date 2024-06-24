import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SearchFieldController extends GetxController {
  static SearchFieldController get instance => Get.find();
  final userRepository = Get.put(UserRepository());
  var query = ''.obs;

  Stream<QuerySnapshot> getResults() {
    return Stream.fromFuture(userRepository.fetchAllUserLogs());
  }

  Widget buildSearchResults(String search) {
    return StreamBuilder<QuerySnapshot>(
      stream: Stream.fromFuture(userRepository.fetchAllUserLogs()),
      builder: (context, snapshot) {
        return (snapshot.connectionState == ConnectionState.waiting)
            ? const Center(
                child: CircularProgressIndicator(color: CCColors.primaryColor,),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  // data contains ALL logs from user
                  var data =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;

                  // Show results that match search
                  if (data['Name'].toString().toLowerCase().contains(search)) {
                    return ListTile(
                      leading: Container(
                        child: data.containsKey('Picture')
                          ? Image.network(data['Picture'])
                          : const Text('No picture!')),
                      title: Text(data['Name'], style: const TextStyle(fontSize: 18),),
                      subtitle: Text(data['Location']),
                      trailing: Text('${data['Rating']}⭐', style: const TextStyle(fontSize: 16),),
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
