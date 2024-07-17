import 'package:culinary_compass/pages/groupinfo_page.dart';
import 'package:culinary_compass/pages/recommendations_page.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/grouprecs_controller.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:culinary_compass/utils/theme/textfield_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsPage extends StatelessWidget {
  final Map<String, dynamic> document;
  final String groupID;
  final groupRecsController = Get.put(GrouprecsController());
  final groupsController = Get.put(GroupsController());
  final userRepository = Get.put(UserRepository());
  GroupsPage({super.key, required this.document, required this.groupID});

  @override
  Widget build(BuildContext context) {
    // Show filter bottom sheet
    void showRecommendations() {
      showModalBottomSheet(
          isDismissible: false,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: CCSizes.spaceBtwItems),
        child: Column(
          children: [
            // TODO: StreamBuilder for text messages
            ElevatedButton(
                style: CCElevatedTextButtonTheme.lightInputButtonStyle,
                onPressed: () async {
                  // circular progress indicator
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: CCColors.primaryColor,
                          ),
                        );
                      });
                  // Pass the json data to Heroku for processing, assigns output to "data"
                  await groupRecsController.herokuAPI(
                      document['MembersUID'].whereType<String>().toList());
                  Get.back(); // close loading indicator
                  showRecommendations();
                },
                child: const Text(
                  'Suggest',
                  style: TextStyle(color: Colors.black),
                )),
            TextField(
              controller: groupsController.chatTextController,
              maxLines: 2,
              decoration: textFieldInputDecoration(
                  hintText: 'Type something', prefixIcon: Icons.text_fields),
            )
          ],
        ),
      ),
    );
  }
}
