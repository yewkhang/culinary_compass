import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/authenticate/authenticate.dart';
import 'package:culinary_compass/authenticate/create_username.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:culinary_compass/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:culinary_compass/utils/constants/loading.dart';

class Wrapper extends StatelessWidget {
  final ImagePicker imagePicker;
  Wrapper({super.key, required this.imagePicker});

  // --------------------- FIREBASE --------------------- //
  // Firebase/Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {

    // return either home or authenticate --> is like the governing class
    // dynamic: hence will listen for any auth changes and correctly display appropriate page
    final myUser = Provider.of<MyUser?>(context);
    if (myUser == null) {
      return const Authenticate();
    } else {
      return FutureBuilder<bool>(
        future: alreadyHasUsername(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // show a loading indicator while checking/waiting
            return const Center(child: Loading());
          } else if (snapshot.hasError) {
            // return error if necessary
            return const Center(child: Text('An error occurred'));
          } else if (snapshot.hasData && snapshot.data == true) {
            // if user has already created username, direct to home page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.off(() => NavigationMenu(imagePicker: imagePicker));
            });
          } else {
            // if user has not created username, direct to username page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Get.off(() => CreateUsernamePage());
            });
          }
          // show a loading indicator while waiting for navigation
          return const Center(child: Loading());
        },
      );
    }
  }

  // helper method to check account has already been created before (has a username)
  Future<bool> alreadyHasUsername() async {
    try {
      final currentUserEmail = _auth.currentUser!.email; // name of document in collection
      final userDoc = await _firestore.collection('Users').doc(currentUserEmail).get();

      if (userDoc.exists) {
        String username = userDoc['Username'];
        return username.isNotEmpty;
      }
    } catch (e) {
      print("Error with alreadyHasUsername() method: $e");
    }
    return false;
  }
}