import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

// ----------------------- DEFAULT SOCIAL PAGE ----------------------- //
class SocialsPage extends StatelessWidget {
  SocialsPage({super.key});

  final ProfileController profileController = Get.put(ProfileController());
  final FriendsDialogController friendsDialogController =
      Get.put(FriendsDialogController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            titleSpacing: 20.0,
            title: const Text("Social",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Friends"),
                Tab(text: "Groups"),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              FriendsList(),
              GroupsList(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                Get.dialog(AddFriendsCreateGroupsDialog());
              },
              backgroundColor: Colors.purple[200],
              child: const Icon(Icons.person_add)),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ));
  }
}
// ----------------------- DEFAULT SOCIAL PAGE ----------------------- //

// ----------------------- DEFAULT POP-UP DIALOG ----------------------- //
class AddFriendsCreateGroupsDialog extends StatelessWidget {
  const AddFriendsCreateGroupsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const Text("Choose Action",
                      style: TextStyle(
                          fontWeight: FontWeight.normal, fontSize: 22.0)),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: "Add Friends"),
                      Tab(text: "Create Groups"),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    AddFriendsDialog(),
                    CreateGroupDialog(),
                  ],
                ))));
  }
}
// ----------------------- DEFAULT POP-UP DIALOG ----------------------- //

// ----------------------- FRIENDS TAB ----------------------- //
class FriendsList extends StatelessWidget {
  FriendsList({super.key});

  final ProfileController profileController = ProfileController.instance;
  final friendsDialogController = FriendsDialogController.instance;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ListView.builder(
        itemCount: profileController.user.value.friendsUsername.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple[400],
              child: GestureDetector(
                onTap: () {
                  Get.dialog(AddFriendsDialog());
                },
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
            title: Text(
                profileController.user.value.friendsUsername.elementAt(index)),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await profileController.deleteFriendFromList(profileController
                    .user.value.friendsUsername
                    .elementAt(index));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Friend successfully removed!")));
              },
            ),
          );
        },
      ),
    );
  }
}
// ----------------------- FRIENDS TAB ----------------------- //

class GroupsList extends StatelessWidget {
  GroupsList({super.key});

  final GroupsController groupsController = Get.put(GroupsController());

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
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    String groupID = snapshot.data!.docs[index].id;
                    var data = snapshot.data!.docs[index].data()
                        as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['Name']),
                    );
                  });
        });
  }
}

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
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add Friends",
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
            TextFormField(
              controller: friendsDialogController.friendUIDTextField,
              decoration: const InputDecoration(hintText: "Enter UID here"),
              validator: (text) {
                if (text == null || text.trim().isEmpty) {
                  return "Friend's UID cannot be blank";
                } else if (!friendsDialogController.uidExists.value) {
                  return "User with UID '${friendsDialogController.friendUIDTextField.text.trim()}' does not exist";
                }
                return null;
              },
              onChanged: (text) async {
                await friendsDialogController.validateUIDExists(text);
              },
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    friendsDialogController.uidExists.value) {
                  await profileController.addFriendToList(
                      friendsDialogController.friendUIDTextField.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text("Friend's UID successfully added!")));
                }
                friendsDialogController.friendUIDTextField.text =
                    ""; // clear controller
              },
              child: const Text("Add Friend"),
            ),
          ],
        ),
      ),
    );
  }
}
// ----------------------- DIALOG: ADDING FRIENDS ----------------------- //

class CreateGroupDialog extends StatelessWidget {
  CreateGroupDialog({super.key});

  final FriendsDialogController friendsDialogController =
      FriendsDialogController.instance;
  final ProfileController profileController = ProfileController.instance;
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController userSearchController = TextEditingController();
  final GroupsController groupsController = Get.put(GroupsController());
  final TagsController nameTagsController = Get.put(TagsController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Create Group",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          TextField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: "Group Name"),
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
                            onDeleted: () => nameTagsController.selectedFriendsNames
                                .remove(element)))
                        .toList(),
                  )),
          ),
          Padding(
            padding: const EdgeInsets.all(CCSizes.defaultSpace),
            child: TypeAheadField(
                controller: userSearchController,
                builder: (context, controller, focusNode) {
                  return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: textFieldInputDecoration(
                          hintText: 'Enter username',
                          prefixIcon: Icons.people_alt));
                },
                itemBuilder: (BuildContext context, String itemData) {
                  return ListTile(
                    title: Text(itemData),
                    tileColor: Colors.white,
                  );
                },
                onSelected: (String suggestion) {
                  // add friends only if selected friends doesn't contain 'suggestion'
                  if (nameTagsController.selectedFriendsNames.contains(suggestion) ==
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
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            style: CCElevatedTextButtonTheme.lightInputButtonStyle,
            onPressed: () async {
              await groupsController.createGroup(groupNameController.text,
                  ['members UID'], nameTagsController.selectedFriendsNames);
              Get.back();
            },
            child: const Text("Create Group"),
          ),
        ],
      ),
    );
  }
}
