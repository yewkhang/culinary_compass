import 'package:culinary_compass/pages/groupinfo_page.dart';
import 'package:culinary_compass/pages/recommendations_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/controllers/grouprecs_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsPage extends StatelessWidget {
  final Map<String, dynamic> document;
  final String groupID;
  final groupRecsController = Get.put(GrouprecsController());
  final userRepository = Get.put(UserRepository());
  GroupsPage({super.key, required this.document, required this.groupID});
  

  @override
  Widget build(BuildContext context) {
    // Show filter bottom sheet
    void showRecommendations() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return RecommendationsPage();
          });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GroupNameContainer(
            groupName: document['Name'],
            onPressed: () {
              Get.to(GroupInfoPage(
                document: document,
                groupID: groupID,
              ));
            }),
        backgroundColor: CCColors.secondaryColor,
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                // circular progress indicator

                // get the data from Firebase and convert to json
                String jsonData = await userRepository.getFirestoreDataAsJson(
                    document['MembersUID'].whereType<String>().toList());
                // Pass the json data to Heroku for processing, assigns output to "data"
                await groupRecsController.herokuAPI(jsonData);
                print(groupRecsController.data.toString());
                showRecommendations();
              },
              child: Text('get JSON')),
        ],
      ),
    );
  }
}
