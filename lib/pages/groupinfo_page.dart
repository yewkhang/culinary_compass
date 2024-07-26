import 'package:culinary_compass/navigation_menu.dart';
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
  final String groupID;
  GroupInfoPage({super.key, required this.groupID});
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
                      controller: controller,
                      focusNode: focusNode,
                      decoration: textFieldInputDecoration(
                          hintText: 'Enter username',
                          prefixIcon: Icons.person));
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
            style: CCElevatedTextButtonTheme.lightInputButtonStyle,
            onPressed: () async {
              List<String> usernames =
                  await groupsController.getListOfFriendUidFromUsername(
                      nameTagsController.selectedFriendsNames);
              await groupsController.addMembersToGroup(
                  groupID,
                  usernames,
                  groupsController.currentGroup.value.membersUID.whereType<String>().toList(),
                  groupsController.currentGroup.value.membersUsername.whereType<String>().toList());
              // reset fields
              nameTagsController.selectedFriendsNames.clear();
              // refresh members list
              groupsController.fetchGroupDetails(groupID);
              Get.back();
              Get.snackbar('', '',
                  titleText: const Text(
                    'Friend Added To Group!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  messageText: const SizedBox(),
                  icon: const Icon(
                    Icons.check_circle_outline_outlined,
                    color: Colors.white,
                  ),
                  backgroundColor: Colors.green,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(20),
                  duration: const Duration(seconds: 2));
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
        child: Obx(() => 
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                groupsController.currentGroup.value.name,
                style: const TextStyle(fontSize: 24),
              ),
              Text('${groupsController.currentGroup.value.membersUID.length} members'),
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
                    children: groupsController.currentGroup.value.membersUsername
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
                                          backgroundColor: Colors.white,
                                          title: 'Remove Member',
                                          middleText:
                                              'Remove $element from group?',
                                          confirm: ElevatedButton(
                                              style: CCElevatedTextButtonTheme
                                                  .lightInputButtonStyle,
                                              onPressed: () async {
                                                await groupsController
                                                    .deleteMembersFromGroup(
                                                        groupID,
                                                        element,
                                                        groupsController.currentGroup.value.membersUID
                                                            .whereType<String>()
                                                            .toList(),
                                                        groupsController.currentGroup.value.membersUsername
                                                            .whereType<String>()
                                                            .toList());
                                                // refresh members list
                                                groupsController.fetchGroupDetails(groupID);
                                                Get.back();
                                                Get.snackbar('', '',
                                                  titleText: Text(
                                                    'Removed $element from group!',
                                                    style: const TextStyle(color: Colors.white, fontSize: 18),
                                                  ),
                                                  messageText: const SizedBox(),
                                                  icon: const Icon(
                                                    Icons.check_circle_outline_outlined,
                                                    color: Colors.white,
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  snackPosition: SnackPosition.BOTTOM,
                                                  margin: const EdgeInsets.all(20),
                                                  duration: const Duration(seconds: 2));
                                              },
                                              child: const Text('Remove user',
                                                  style: TextStyle(
                                                      color: Colors.black))),
                                          cancel: ElevatedButton(
                                              style: CCElevatedTextButtonTheme
                                                  .unselectedButtonStyle,
                                              onPressed: () => Get.back(),
                                              child: const Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.black),
                                              )),
                                        );
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
                        Get.defaultDialog(
                          backgroundColor: Colors.white,
                          title: 'Delete Group',
                          middleText:
                              'Are you sure you want to delete the whole group?',
                          confirm: ElevatedButton(
                              style:
                                  CCElevatedTextButtonTheme.lightInputButtonStyle,
                              onPressed: () async {
                                await groupsController.deleteGroup(groupID);
                                // get back to socials page after deleting group
                                Get.offAll(const NavigationMenu(pageIndex: 3,), transition: Transition.leftToRight);
                                Get.snackbar('', '',
                                  titleText: const Text(
                                    'Group Deleted!',
                                    style: TextStyle(color: Colors.white, fontSize: 18),
                                  ),
                                  messageText: const SizedBox(),
                                  icon: const Icon(
                                    Icons.check_circle_outline_outlined,
                                    color: Colors.white,
                                  ),
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(20),
                                  duration: const Duration(seconds: 2));
                              },
                              child: const Text('Delete Group',
                                  style: TextStyle(color: Colors.black))),
                          cancel: ElevatedButton(
                              style:
                                  CCElevatedTextButtonTheme.unselectedButtonStyle,
                              onPressed: () => Get.back(),
                              child: const Text('Cancel',
                                  style: TextStyle(color: Colors.black))),
                        );
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
