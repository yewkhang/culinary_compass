import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:flutter/material.dart';

class GroupInfoPage extends StatelessWidget {
  final Map<String, dynamic> document;
  final String groupID;
  GroupInfoPage({super.key, required this.document, required this.groupID});
  final GroupsController groupsController = GroupsController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.edit))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(CCSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              document['Name'],
              style: const TextStyle(fontSize: 24),
            ),
            Text('${document['MembersUID'].length} members'),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: () {
                  // open dialog box to add user
                },
                style: CCElevatedTextButtonTheme.lightInputButtonStyle,
                child: const Text('Add Members', style: TextStyle(color: Colors.black),)),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Members',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: ListView(
                children: document["MembersUsername"]
                    .toList()
                    .map<Widget>((element) => Text(element))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
