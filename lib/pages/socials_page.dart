import 'package:culinary_compass/utils/controllers/friendsdialog_controller.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ----------------------- DEFAULT SOCIAL PAGE ----------------------- //
class SocialsPage extends StatelessWidget {
  
  SocialsPage({super.key});

  final ProfileController profileController = Get.put(ProfileController());
  final FriendsDialogController friendsDialogController = Get.put(FriendsDialogController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 20.0,
          title: const Text(
            "Social",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0)
          ),
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
          child: const Icon(Icons.person_add)
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      )
    );
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
            title: const Text(
              "Choose Action",
              style: TextStyle(fontWeight: FontWeight.normal, fontSize: 22.0)
            ),
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
              const CreateGroupDialog(),
            ],
          )
        )
      )
    );
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
            title: Text(profileController.user.value.friendsUsername.elementAt(index)),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await profileController.deleteFriendFromList(profileController.user.value.friendsUsername.elementAt(index));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Friend successfully removed!")
                  )
                );
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
  
  const GroupsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, ////////////////////////////////////// add actual logic later
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.purple,
            child: GestureDetector(
              onTap: () {
                Get.dialog(CreateGroupDialog());
              },
              child: const Icon(Icons.group, color: Colors.white),
            ),
          ),
          title: const Text("Group Name"),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              ////////////////////////////////////////// add delete groups functionality
            },
          ),
        );
      },
    );
  }
}


// ----------------------- DIALOG: ADDING FRIENDS ----------------------- //
class AddFriendsDialog extends StatelessWidget {

  AddFriendsDialog({super.key});

  final ProfileController profileController = ProfileController.instance;
  final FriendsDialogController friendsDialogController = FriendsDialogController.instance;
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

            const Text("Add Friends", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),

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
              onChanged:(text) async {
                await friendsDialogController.validateUIDExists(text);
              },
            ),

            const SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && friendsDialogController.uidExists.value) {
                  await profileController.addFriendToList(friendsDialogController.friendUIDTextField.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Friend's UID successfully added!")
                    )
                  );
                }
                friendsDialogController.friendUIDTextField.text = ""; // clear controller
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


class CreateGroupDialog extends StatefulWidget {
  
  const CreateGroupDialog({super.key});

  @override
  State<CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<CreateGroupDialog> {

  bool isChecked = false;
  final FriendsDialogController friendsDialogController = FriendsDialogController.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          const Text("Create Group", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),

          const TextField(
            decoration: InputDecoration(hintText: "Group Name"),
          ),

          const SizedBox(height: 20.0),

          const Text("Who would you like to add?"),

          const TextField(
            decoration: InputDecoration(hintText: "Enter Friend's Username"),
            // onChanged: ,
          ),

          Expanded(
            child: ListView.builder(
              itemCount: 5, ////////////////////////////////////// add actual logic later
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text("Name ${index + 1}"),
                  value: isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              ////////////////////////////////////////////////////// create group logic
            },
            child: const Text("Create Group"),
          ),
        ],
      ),
    );
  }
}