import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class UsernameCreationController extends GetxController {
  
  // --------------------- FIREBASE --------------------- //
  // Firebase/Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  // --------------------- GETTERS --------------------- //
  // (controller).currentUser -> 
  User get currentUser => _auth.currentUser!;
  // (controller).usersCollection
  CollectionReference get usersCollection => _firestore.collection("Users");

  static UsernameCreationController get instance => Get.find();

  TextEditingController usernameTextField = TextEditingController();

  // state to check whether username is already created
  RxBool usernameCreated = false.obs;
  // state to manage whether username has already been taken
  RxBool usernameAlreadyTaken = true.obs;
  // state to manage loading state (animation)
  RxBool isLoading = false.obs;
  

  // -------------------- For usernameCreated -------------------- //
  // FOR THIS IMPLEMENTATION OF OUR APP, NOT CURRENTLY USED
  // to check if username has already been taken by other users
  Future<void> checkIfUsernameIsPresent() async {
    try {
      final currentUserEmail = _auth.currentUser!.email; // name of document in collection
      final userDoc = await _firestore.collection('Users').doc(currentUserEmail).get();

      if (userDoc.exists) {
        String cloudUsername = userDoc['Username'];
        usernameCreated.value = (cloudUsername == "");
      }
    } catch (e) {
      print(e);
    }
  }
  // -------------------- For usernameCreated -------------------- //
  

  // -------------------- For usernameAlreadyTaken -------------------- //
  // to check if username has already been taken by other users
  Future<void> checkIfUsernameAlreadyTaken(String username) async {
    try {
      // check if username exists in any user document
      final snapshot = await usersCollection.where("Username", isEqualTo: username).get();
      usernameAlreadyTaken.value = snapshot.docs.isNotEmpty;
    } catch (e) {
      print(e);
    }
  }
  // -------------------- For usernameAlreadyTaken -------------------- //

  // Update Username (from initial username creation page)
  Future<void> finalUpdateUsernameToFirebase() async {
    try {
      await usersCollection.doc(currentUser.email).update({"Username": usernameTextField.text});
    } catch (e) {
      print(e);
    }
  }
}