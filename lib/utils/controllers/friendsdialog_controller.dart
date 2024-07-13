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

  // state to manage existence of UID
  RxBool uidExists = true.obs;

  // update state based on validation result
  Future<void> validateUIDExists(String? uid) async {
    if (uid != null && uid.isNotEmpty) {
      await validateFriendsWithFirebase(uid).then((exists) {
        uidExists.value = exists;
      });
    }
  }

  // helper method for validateUIDExists
  Future<bool> validateFriendsWithFirebase(String uid) async {
    try {
      final snapshot = await _firestore.collection("Users").where("UID", isEqualTo: uid).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print(e);
      return false;
    }
  }
}