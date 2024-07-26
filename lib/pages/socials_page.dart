import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/pages/groups_page.dart';
import 'package:culinary_compass/pages/yourlogs_page.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/sizes.dart';
import 'package:culinary_compass/utils/controllers/friendsdialog_controller.dart';
import 'package:culinary_compass/utils/controllers/groups_controller.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/utils/controllers/tags_controller.dart';
import 'package:culinary_compass/utils/custom_widgets.dart';
import 'package:culinary_compass/utils/theme/elevated_button_theme.dart';
import 'package:culinary_compass/utils/theme/textfield_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

// ----------------------- DEFAULT SOCIAL PAGE ----------------------- //
class SocialsPage extends StatelessWidget {
  SocialsPage({super.key});

  final ProfileController profileController = Get.put(ProfileController());
  final GroupsController groupsController = Get.put(GroupsController());
  final FriendsDialogController friendsDialogController =
      Get.put(FriendsDialogController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          //background color of main page
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: CCColors.primaryColor,
            title: const Text("Social", style: TextStyle(fontSize: 25.0)),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                color: Colors.white,
                child: const TabBar(
                  labelColor: CCColors.primaryColor,
                  indicatorColor: Colors.amberAccent,
                  tabs: [
                    Tab(text: "Friends"),
                    Tab(text: "Groups"),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              FriendsList(),
              GroupsList(),
            ],
          ),
          floatingActionButton: ElevatedButton(
              onPressed: () {
                Get.dialog(const AddFriendsCreateGroupsDialog());
              },
              style: CCElevatedIconButtonTheme.lightInputButtonStyle,
              child: const Icon(
                Icons.person_add_alt_1,
                color: Colors.black,
              )),
        ));
  }
}
// ----------------------- DEFAULT SOCIAL PAGE ----------------------- //

// ----------------------- DEFAULT POP-UP DIALOG ----------------------- //
class AddFriendsCreateGroupsDialog extends StatelessWidget {
  const AddFriendsCreateGroupsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: CCColors.primaryColor,
              centerTitle: true,
              title: const Text("Choose Action",
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 22.0)),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: Container(
                  color: Colors.white,
                  child: const TabBar(
                    labelColor: CCColors.primaryColor,
                    indicatorColor: Colors.amberAccent,
                    overlayColor: WidgetStateColor.transparent,
                    tabs: [
                      Tab(text: "Add Friends"),
                      Tab(text: "Create Groups"),
                    ],
                  ),
                ),
              ),
            ),
            body: TabBarView(
              children: [
                AddFriendsDialog(),
                CreateGroupDialog(),
              ],
            )));
  }
}
// ----------------------- DEFAULT POP-UP DIALOG ----------------------- //

// ----------------------- FRIENDS TAB ----------------------- //
class FriendsList extends StatelessWidget {
  FriendsList({super.key});

  final ProfileController profileController = ProfileController.instance;
  final GroupsController groupsController = Get.put(GroupsController());
  final friendsDialogController = FriendsDialogController.instance;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: profileController.user.value.friendsUsername.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[400],
              child: const Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              profileController.user.value.friendsUsername.elementAt(index),
            ),
            onTap: () async {
              List<String> friendsUID = await groupsController
                  .getListOfFriendUidFromUsername(List.filled(
                      1,
                      profileController.user.value.friendsUsername
                          .elementAt(index)));
              String UID = friendsUID[0];
              Get.to(() =>
                  YourlogsPage(
                    fromHomePage: true,
                    friendUID: UID,
                  ),
                  transition: Transition.rightToLeftWithFade);
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await profileController.deleteFriendFromList(profileController
                    .user.value.friendsUsername
                    .elementAt(index));
                Get.snackbar('', '',
                    titleText: const Text(
                      'Friend Removed!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    messageText: const SizedBox(),
                    icon: const Icon(
                      Icons.check_circle_outline_outlined,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20));
              },
            ),
          );
        },
      ),
    );
  }
}
// ----------------------- FRIENDS TAB ----------------------- //

// ----------------------- GROUPS TAB ----------------------- //
class GroupsList extends StatelessWidget {
  GroupsList({super.key});

  final GroupsController groupsController = GroupsController.instance;
  final ProfileController profileController = ProfileController.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: groupsController.fetchAllUserGroups(),
        builder: (context, snapshot) {
          return (snapshot.connectionState == ConnectionState.waiting)
              ? const Center(
                  // Retrieving from Firestore
                  child: CircularProgressIndicator(
                    color: CCColors.primaryColor,
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    String groupID = snapshot.data!.docs[index].id;
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return Slidable(
                      endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                                backgroundColor: Colors.red,
                                icon: Icons.delete,
                                onPressed: (context) => Get.defaultDialog(
                                      backgroundColor: Colors.white,
                                      title: 'Leave Group',
                                      middleText:
                                          'Are you sure you want to leave this group?',
                                      confirm: ElevatedButton(
                                          style: CCElevatedTextButtonTheme
                                              .lightInputButtonStyle,
                                          onPressed: () async {
                                            // assumes user does not change their username
                                            await groupsController
                                                .deleteMembersFromGroup(
                                                    groupID,
                                                    profileController
                                                        .user.value.username,
                                                    data['MembersUID']
                                                        .whereType<String>()
                                                        .toList(),
                                                    data['MembersUsername']
                                                        .whereType<String>()
                                                        .toList());
                                            Get.back();
                                          },
                                          child: const Text(
                                            'Leave Group',
                                            style:
                                                TextStyle(color: Colors.black),
                                          )),
                                      cancel: ElevatedButton(
                                          style: CCElevatedTextButtonTheme
                                              .unselectedButtonStyle,
                                          onPressed: () => Get.back(),
                                          child: const Text(
                                            'Cancel',
                                            style:
                                                TextStyle(color: Colors.black),
                                          )),
                                    ))
                          ]),
                      child: ListTile(
                        title: Text(data['Name']),
                        onTap: () {
                          Get.to(() =>
                            GroupsPage(
                              document: data,
                              groupID: groupID,
                            ), transition: Transition.rightToLeftWithFade
                          );
                        },
                      ),
                    );
                  });
        });
  }
}
// ----------------------- GROUPS TAB ----------------------- //

// ----------------------- DIALOG: ADDING FRIENDS ----------------------- //
class AddFriendsDialog extends StatelessWidget {
  AddFriendsDialog({super.key});

  final ProfileController profileController = ProfileController.instance;
  final FriendsDialogController friendsDialogController =
      FriendsDialogController.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CCSizes.spaceBtwItems),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Friends",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: friendsDialogController.friendUIDTextField,
              decoration: textFieldInputDecoration(
                  hintText: "Enter UID here", prefixIcon: Icons.person),
              validator: (text) {
                if (text == null || text.trim().isEmpty) {
                  return "Friend's UID cannot be blank!";
                } else if (friendsDialogController.uidBelongsToUser.value) {
                  return "You cannot add yourself as a friend!";
                } else if (!friendsDialogController.uidExists.value) {
                  return "User with UID '${friendsDialogController.friendUIDTextField.text.trim()}' does not exist";
                } else if (friendsDialogController.uidAlreadyAdded.value) {
                  return "Already added a friend with this UID!";
                }
                return null;
              },
              onChanged: (text) async {
                friendsDialogController.checkUIDBelongsToUser(text);
                await friendsDialogController.validateUIDExists(text);
                await friendsDialogController.overallValidationUID(text);
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              style: CCElevatedTextButtonTheme.lightInputButtonStyle,
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    friendsDialogController.uidExists.value) {
                  await profileController.addFriendToList(
                      friendsDialogController.friendUIDTextField.text);
                  Get.back();
                  Get.snackbar('', '',
                      titleText: const Text(
                        'Friend Added!',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      messageText: const SizedBox(),
                      icon: const Icon(
                        Icons.check_circle_outline_outlined,
                        color: Colors.white,
                      ),
                      backgroundColor: Colors.green,
                      snackPosition: SnackPosition.BOTTOM,
                      margin: const EdgeInsets.all(20));
                }
                friendsDialogController.friendUIDTextField.text =
                    ""; // clear controller
              },
              child: const Text(
                "Add Friend",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// ----------------------- DIALOG: ADDING FRIENDS ----------------------- //

// ----------------------- DIALOG: CREATING GROUPS ----------------------- //
class CreateGroupDialog extends StatelessWidget {
  CreateGroupDialog({super.key});

  final FriendsDialogController friendsDialogController =
      FriendsDialogController.instance;
  final ProfileController profileController = ProfileController.instance;
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController userSearchController = TextEditingController();
  final GroupsController groupsController = GroupsController.instance;
  final TagsController nameTagsController = Get.put(TagsController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Create Group",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          Form(
            key: _formKey,
            child: TextFormField(
              controller: groupNameController,
              decoration: textFieldInputDecoration(
                  hintText: 'Group Name', prefixIcon: Icons.people_alt),
              validator: (text) {
                if (text == null || text.trim().isEmpty) {
                  return "Group's Name cannot be blank";
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20.0),
          // ----- SELECTED FRIENDS DISPLAY ----- //
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: CCSizes.defaultSpace),
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
                if (nameTagsController.selectedFriendsNames
                        .contains(suggestion) ==
                    false) {
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
          const SizedBox(height: 20.0),
          ElevatedButton(
            style: CCElevatedTextButtonTheme.lightInputButtonStyle,
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                List<String> UIDsToAdd =
                    await groupsController.getListOfFriendUidFromUsername(
                        nameTagsController.selectedFriendsNames);
                await groupsController.createGroup(
                    groupNameController.text,
                    // add current user's UID to list of members
                    UIDsToAdd..add(profileController.user.value.uid),
                    // add current user's username to list of names
                    List.from(nameTagsController.selectedFriendsNames)
                      ..add(profileController.user.value.username),
                    profileController.user.value.uid);
                // clear values
                nameTagsController.selectedFriendsNames.clear();
                Get.back();
                Get.snackbar('', '',
                    titleText: const Text(
                      'Group Created!',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    messageText: const SizedBox(),
                    icon: const Icon(
                      Icons.check_circle_outline_outlined,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20));
              }
            },
            child: const Text(
              "Create Group",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
// ----------------------- DIALOG: CREATING GROUPS ----------------------- //
