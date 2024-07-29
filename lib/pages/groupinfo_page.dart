import 'package:culinary_compass/navigation_menu.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/controllers/tags_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:culinary_compass/utils/theme/defaultdialog_theme.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:culinary_compass/utils/theme/snackbar_theme.dart';
import 'package:culinary_compass/utils/theme/textfield_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GroupInfoPage extends StatelessWidget {
  final String groupID;
  GroupInfoPage({super.key, required this.groupID, required this.imagePicker});
  final GroupsController groupsController = GroupsController.instance;
  final ProfileController profileController = ProfileController.instance;
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController userSearchController = TextEditingController();
  final TagsController nameTagsController = Get.put(TagsController());
  final ImagePicker imagePicker;

  void showGetxBottomSheet() {
    Get.bottomSheet(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        Column(children: [
          // ----- SELECTED FRIENDS DISPLAY ----- //
          Padding(
            padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
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
          Padding(
            padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
            child: TypeAheadField(
                controller: userSearchController,
                builder: (context, controller, focusNode) {
                  return TextField(
                      key: Key("GroupAddFriendDialog"),
                      controller: controller,
                      focusNode: focusNode,
                      decoration: textFieldInputDecoration(
                          hintText: 'Enter username',
                          prefixIcon: Icons.person));
                },
                itemBuilder: (BuildContext context, String itemData) {
                  return ListTile(
                    key: Key("GroupAddFriendDialogListTile$itemData"),
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
                      !groupsController.currentGroup.value.membersUsername
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
          ),
          ElevatedButton(
            key: Key("GroupAddFriendDialogButton"),
            style: CCElevatedTextButtonTheme.lightInputButtonStyle,
            onPressed: () async {
              List<String> usernames =
                  await groupsController.getListOfFriendUidFromUsername(
                      nameTagsController.selectedFriendsNames);
              await groupsController.addMembersToGroup(
                  groupID,
                  usernames,
                  groupsController.currentGroup.value.membersUID
                      .whereType<String>()
                      .toList(),
                  groupsController.currentGroup.value.membersUsername
                      .whereType<String>()
                      .toList());
              // reset fields
              nameTagsController.selectedFriendsNames.clear();
              // refresh members list
              groupsController.fetchGroupDetails(groupID);
              Get.back();
              CCSnackBarTheme.defaultSuccessSnackBar('Friend Added To Group!');
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
    bool isAdmin = groupsController.currentGroup.value.admins
        .whereType<String>()
        .toList()
        .contains(profileController.user.value.uid);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
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
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupsController.currentGroup.value.name,
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                  '${groupsController.currentGroup.value.membersUID.length} members'),
              const SizedBox(height: 30),
              const SizedBox(height: 30),
              const Text(
                'Members',
                style: TextStyle(fontSize: 20),
              ),
              const Divider(),
              Expanded(
                child: Obx(() {
                  return ListView(
                    children: groupsController
                        .currentGroup.value.membersUsername
                        .toList()
                        .map<Widget>((element) => ListTile(
                              title: Text(element),
                              // show delete icon for users if admin, don't show it for themselves
                              trailing: isAdmin &&
                                      element.toString() !=
                                          profileController.user.value.username
                                  ? IconButton(
                                      onPressed: () async {
                                        return CCDefaultDialogTheme
                                            .defaultGetxDialog(
                                                'Remove Member',
                                                'Remove $element from group?',
                                                'Remove Member', () async {
                                          await groupsController
                                              .deleteMembersFromGroup(
                                                  groupID,
                                                  element,
                                                  groupsController.currentGroup
                                                      .value.membersUID
                                                      .whereType<String>()
                                                      .toList(),
                                                  groupsController.currentGroup
                                                      .value.membersUsername
                                                      .whereType<String>()
                                                      .toList());
                                          // refresh members list
                                          groupsController
                                              .fetchGroupDetails(groupID);
                                          Get.back();
                                          CCSnackBarTheme.defaultSuccessSnackBar(
                                              'Removed $element from group!');
                                        }, Key("RemoveMemberFromGroup"));
                                      },
                                      icon: const Icon(Icons.delete),
                                    )
                                  : const SizedBox(),
                            ))
                        .toList(),
                  );
                }),
              ),
              isAdmin
                  ? ElevatedButton(
                      style: CCElevatedTextButtonTheme.lightInputButtonStyle,
                      onPressed: () async {
                        return CCDefaultDialogTheme.defaultGetxDialog(
                            'Delete Group',
                            'Are you sure you want to delete the whole group?',
                            'Delete Group', () async {
                          await groupsController.deleteGroup(groupID);
                          // get back to socials page after deleting group
                          Get.offAll(
                              NavigationMenu(
                                imagePicker: imagePicker,
                                pageIndex: 3,
                              ),
                              transition: Transition.leftToRight);
                          CCSnackBarTheme.defaultSuccessSnackBar(
                              'Group Deleted!');
                        }, Key("LeaveGroupButton"));
                      },
                      child: const Text(
                        'Delete Group',
                        style: TextStyle(color: Colors.black),
                      ))
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
