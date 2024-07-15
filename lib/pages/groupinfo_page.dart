import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/controllers/tags_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:culinary_compass/utils/theme/textfield_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

class GroupInfoPage extends StatelessWidget {
  final Map<String, dynamic> document;
  final String groupID;
  GroupInfoPage({super.key, required this.document, required this.groupID});
  final GroupsController groupsController = GroupsController.instance;
  final ProfileController profileController = ProfileController.instance;
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController userSearchController = TextEditingController();
  final TagsController nameTagsController = Get.put(TagsController());

  void showGetxBottomSheet() {
    Get.bottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        Column(children: [
          // ----- SELECTED FRIENDS DISPLAY ----- //
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: CCSizes.spaceBtwItems),
            child: Obx(() => nameTagsController.selectedFriendsNames.isEmpty
                ? const Center(
                    child: Text('Add friends'),
                  )
                : Wrap(
                    children: nameTagsController.selectedFriendsNames
                        .map((element) => CCTagsContainer(
                            label: Text(element),
                            deleteIcon: const Icon(Icons.clear),
                            onDeleted: () => nameTagsController
                                .selectedFriendsNames
                                .remove(element)))
                        .toList(),
                  )),
          ),
          // FRIENDS SUGGESTIONS
          TypeAheadField(
              controller: userSearchController,
              builder: (context, controller, focusNode) {
                return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: textFieldInputDecoration(
                        hintText: 'Enter username', prefixIcon: Icons.person));
              },
              itemBuilder: (BuildContext context, String itemData) {
                return ListTile(
                  title: Text(itemData),
                  tileColor: Colors.white,
                );
              },
              onSelected: (String suggestion) {
                // add friends only if selected friends doesn't contain 'suggestion'
                // or is not already in the group
                if (nameTagsController.selectedFriendsNames
                            .contains(suggestion) ==
                        false &&
                    !document['MembersUsername']
                        .whereType<String>()
                        .toList()
                        .contains(suggestion)) {
                  nameTagsController.selectedFriendsNames.add(suggestion);
                  // clear text field upon selection of a friend
                  userSearchController.clear();
                }
              },
              suggestionsCallback: (String query) {
                // list of user's friends to select from
                return groupsController.getFriendSuggestions(
                    query, profileController.user.value.friendsUsername);
              }),
          ElevatedButton(
            style: CCElevatedTextButtonTheme.lightInputButtonStyle,
            onPressed: () async {
              List<String> usernames =
                  await groupsController.getListOfFriendUidFromUsername(
                      nameTagsController.selectedFriendsNames);
              await groupsController.addMembersToGroup(
                  groupID,
                  usernames,
                  document['MembersUID'].whereType<String>().toList(),
                  document['MembersUsername'].whereType<String>().toList());
              // reset fields
              nameTagsController.selectedFriendsNames.clear();
              Get.back();
            },
            child: const Text(
              'Add Members',
              style: TextStyle(color: Colors.black),
            ),
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = document['Admins']
        .whereType<String>()
        .toList()
        .contains(profileController.user.value.uid);
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: CCSizes.defaultSpace),
            child: ElevatedButton(
                onPressed: () {
                  // open dialog box to add user
                  showGetxBottomSheet();
                },
                style: CCElevatedTextButtonTheme.lightInputButtonStyle,
                child: const Text(
                  'Add Members',
                  style: TextStyle(color: Colors.black),
                )),
          ),
        ],
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
                    .map<Widget>((element) => ListTile(
                          title: Text(element),
                          // show delete icon for users if admin, don't show it for themselves
                          trailing: isAdmin &&
                                  element.toString() !=
                                      profileController.user.value.username
                              ? IconButton(
                                  onPressed: () async {
                                    Get.defaultDialog(
                                      title: 'Remove Member',
                                      middleText: 'Remove $element from group?',
                                      confirm: ElevatedButton(
                                          onPressed: () async {
                                            await groupsController
                                                .deleteMembersFromGroup(
                                                    groupID,
                                                    element,
                                                    document['MembersUID']
                                                        .whereType<String>()
                                                        .toList(),
                                                    document['MembersUsername']
                                                        .whereType<String>()
                                                        .toList());
                                            Get.back();
                                          },
                                          child: const Text('Remove user')),
                                      cancel: ElevatedButton(
                                          onPressed: () => Get.back(),
                                          child: const Text('Cancel')),
                                    );
                                  },
                                  icon: const Icon(Icons.delete),
                                )
                              : const SizedBox(),
                        ))
                    .toList(),
              ),
            ),
            ElevatedButton(
                style: CCElevatedTextButtonTheme.lightInputButtonStyle,
                onPressed: () async {
                  Get.defaultDialog(
                    title: 'Delete Group',
                    middleText:
                        'Are you sure you want to delete the whole group?',
                    confirm: ElevatedButton(
                        onPressed: () async {
                          await groupsController.deleteGroup(groupID);
                          Get.back();
                        },
                        child: const Text('Delete Group')),
                    cancel: ElevatedButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel')),
                  );
                },
                child: const Text('Delete Group', style: TextStyle(color: Colors.black),))
          ],
        ),
      ),
    );
  }
}
