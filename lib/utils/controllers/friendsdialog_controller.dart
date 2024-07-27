import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FriendsDialogController extends GetxController {
  
  // --------------------- FIREBASE --------------------- //
  // Firebase/Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // --------------------- VARIABLES --------------------- //
  // Abstract away the image capturing part
  ProfileController profileController = ProfileController.instance;


  // --------------------- GETTERS --------------------- //
  // (controller).currentUser -> 
  User get currentUser => _auth.currentUser!;
  // (controller).usersCollection
  CollectionReference get usersCollection => _firestore.collection("Users");
  // (controller).userStream
  Stream<DocumentSnapshot> get userStream => usersCollection.doc(currentUser.email).snapshots();

  static FriendsDialogController get instance => Get.find();

  TextEditingController friendUIDTextField = TextEditingController();
  TextEditingController groupNameTextField = TextEditingController();
  TextEditingController friendUsernameTextField = TextEditingController();


  // state to manage whether UID is actually the user's own UID (should not be able to add)
  RxBool uidBelongsToUser = true.obs;
  // state to manage existence of UID (if there is a valid UID)
  RxBool uidExists = true.obs;
  // state to manage whether UID has already been added by the user and if UID exists
  RxBool uidAlreadyAdded = true.obs;


  // -------------------- For uidBelongsToUser -------------------- //
  bool checkUIDBelongsToUser(String uid) {
    final currentUserUID = _auth.currentUser!.uid;

    return uidBelongsToUser.value = (currentUserUID == uid);
  }
  // -------------------- For uidBelongsToUser -------------------- //





  // -------------------- For uidExists -------------------- //
  // helper method to update state based on validation result with Firebase
  Future<void> validateUIDExists(String? uid) async {
    // if the UID text controller is not null/empty
    if (uid != null && uid.isNotEmpty) {
      await validateFriendsWithFirebase(uid).then((exists) {
        uidExists.value = exists;
      });
    }
  }

  // helper method for validateUIDExists
  Future<bool> validateFriendsWithFirebase(String uid) async {
    try {
      // check if UID exists in any user document
      final snapshot = await _firestore.collection("Users").where("UID", isEqualTo: uid).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print(e);
      return false;
    }
  }
  // -------------------- For uidExists -------------------- //





  // -------------------- For uidAlreadyAdded -------------------- //
  // helper method to check if friend's UID is already added
  Future<bool> alreadyAddedFriend(String friendUID) async {
    try {
      final currentUserEmail = _auth.currentUser!.email; // name of document in collection
      final userDoc = await _firestore.collection('Users').doc(currentUserEmail).get();

      if (userDoc.exists) {
        List<dynamic> friendsList = userDoc['FriendsUID'];
        // check if the friend's UID is already added into the friend's UID list
        if (friendsList.contains(friendUID)) {
          return true;
        } else {
          return false;
        }
      }
    } catch (e) {
      print("Error with alreadyAddedFriend() method: $e");
    }
    return false;
  }

  // overall method to validate both if UID exists AND friend is not already added beforehand
  // returns true if valid, returns false if invalid
  Future<bool> overallValidationUID(String? uid) async {
    bool friendHasNotBeenAdded = !(await alreadyAddedFriend(uid!));
    // uidExists handled by validateUIDExists which is called in socials_page.dart
    if (uidExists.value && friendHasNotBeenAdded) {
      return uidAlreadyAdded.value = false;
    } else {
      return uidAlreadyAdded.value = true;
    }
  }
  // -------------------- For uidAlreadyAdded -------------------- //
}