import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/misc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Controllers
import 'package:culinary_compass/utils/controllers/profile_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  // controller for profile, manages updating to firestore
  final ProfileController profileController = ProfileController.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: CCColors.primaryColor,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: profileController.userStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            String profileImageURL = userData["Profile Image"] ?? "";

            return Obx(
              () => ListView(
                children: [
                  const SizedBox(height: 25.0),
              
                  // Profile Picture
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // to display profile image if there is one on Firestore
                            // Unfortunately, this implementation will have to do, using Obx solely
                            // does not display updated profile picture correctly
                            profileImageURL != ""
                              ? CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage(userData["Profile Image"])
                              )
                              : CircleAvatar(
                                radius: 60,
                                backgroundImage: Image.asset("lib/images/user-profile-avatar.jpg").image,
                              ),
                            Positioned(
                              bottom: -10,
                              left: 85,
                              child: IconButton(
                                onPressed: () {
                                  profileController.uploadProfileImage();
                                },
                                icon: const Icon(Icons.add_a_photo),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
              
                  const SizedBox(height: 10.0),
              
                  Text(
                    profileController.currentUser.email!,
                    textAlign: TextAlign.center,
                  ),
              
                  const SizedBox(height: 20.0),
              
                  // User Details
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Text(
                      "User Details",
                      style: TextStyle(color: Colors.grey[600])
                    ),
                  ),
              
                  // Username
                  ProfileUneditableTextBox(
                    field: "Username",
                    text: profileController.user.value.username,
                  ),
              
                  // User's uid
                  ProfileUneditableTextBox(
                    field: "UID",
                    text: profileController.user.value.uid,
                  ),
              
                  // Bio/Description
                  ProfileTextboxEditable(
                    sectionName: "Bio",
                    text: profileController.user.value.bio,
                    onPressed: () => editField("Bio")
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}")
            );
          } else {
            return const Center(
              child: CircularProgressIndicator()
            );
          }
        }
      )
    );
  }

  // To edit user detail field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.white)
        ),
        content: TextField(
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: const TextStyle(color: Colors.grey)
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // Cancel Button
          TextButton(
            child: const Text("Cancel", style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),

          // Save Button
          TextButton(
            child: const Text("Save", style: TextStyle(color: Colors.white)),
            onPressed: () async {
              await profileController.updateTextField(field, newValue);
              await profileController.fetchUserDetails();
              Navigator.pop(context);
            },
          )
        ],
      )
    );
  }

}