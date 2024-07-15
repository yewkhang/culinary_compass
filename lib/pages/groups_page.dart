import 'package:culinary_compass/pages/groupinfo_page.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsPage extends StatelessWidget {
  final Map<String, dynamic> document;
  final String groupID;
  const GroupsPage({super.key, required this.document, required this.groupID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: GroupNameContainer(
          groupName: document['Name'], 
          onPressed: (){
            Get.to(GroupInfoPage(document: document, groupID: groupID,));
          }),
        backgroundColor: CCColors.secondaryColor,
      ),
    );
  }
}
