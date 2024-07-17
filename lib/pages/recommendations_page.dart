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
  RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TextField(
              onChanged: (value) {
              },
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  focusColor: Colors.transparent,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Search logs',
                  contentPadding: EdgeInsets.symmetric(
                      vertical: BorderSide.strokeAlignCenter)),
            ),
          ),
          actions: [
            IconButton(
                // can use Get.to()
                onPressed: () => (),
                icon: const Icon(Icons.filter_alt))
          ],
        backgroundColor: CCColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: grouprecsController.data.length,
            itemBuilder: (context, index) {
              var tileData = grouprecsController.data[index];
              String consolidatedDishNames = grouprecsController.consolidateDishNames(tileData);
              return ListTile(
                title: Text(tileData['Location']),
                subtitle: Text(consolidatedDishNames),
                trailing: Text('${tileData['average_rating']}⭐'),
                onTap: () { // user selects the choice they want to suggest
                  String location = tileData['Location'];
                  String averageRating = tileData['average_rating'].toString();
                  String suggestionText = "Let's eat at $location! \n$consolidatedDishNames \n$averageRating";
                  // assign suggestion text to chat Textfield
                  groupsController.chatTextController.text = suggestionText;
                  // go back to groups page
                  Get.back();
                },
              );
            }),
      ),
    );
  }
}
