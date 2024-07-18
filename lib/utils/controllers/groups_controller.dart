import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/models/groups_model.dart';
import 'package:culinary_compass/models/messages_model.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupsController extends GetxController {
  // --------------------- FIREBASE --------------------- //
  // Firebase/Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --------------------- VARIABLES --------------------- //
  // User Repo for methods
  final UserRepository userRepository = Get.put(UserRepository());
  final ProfileController profileController = ProfileController.instance;

  // --------------------- GETTERS --------------------- //
  static GroupsController get instance => Get.find();

  // --------------------- CONTROLLERS --------------------- //
  // chat textfield controller
  final TextEditingController chatTextController = TextEditingController();

  // --------------------- OBS VARIABLES --------------------- //
  // to be initialised every time group info page is accessed
  Rx<Groups> currentGroup = Groups.empty().obs;

  // to clear the controller
  void reset() {
    currentGroup(Groups.empty());
  }

  // fetch group details from Firebase document
  Future<void> fetchGroupDetails(String groupID) async {
    try {
      final Groups currentGroup = await userRepository.fetchUserGroupDetails(groupID);
      this.currentGroup(currentGroup);
    } catch (e) {
      currentGroup(Groups.empty());
    }
  }

  // fetch all groups that user is in
  Stream<QuerySnapshot> fetchAllUserGroups() {
    Stream<QuerySnapshot> result = _db
        .collection("Groups")
        // select logs where list of MembersUID contains user UID
        .where('MembersUID', arrayContains: _auth.currentUser!.uid)
        .snapshots();
    return result;
  }

  Future<void> createGroup(String name, List<String> membersUID,
      List<String> membersUsername) async {
    // create a document reference in Firestore
    DocumentReference ref = _db.collection('Groups').doc();
    // get the ID of the new document reference. This will be the group's ID
    String groupID = ref.id;
    // add UID and Name of user making the group
    membersUID.add(profileController.user.value.uid);
    List<String> finalGroupMembersUsername = List.from(membersUsername)
      ..add(profileController.user.value.username);
    // Create Groups Model for new group
    final newGroup = Groups(
        name: name,
        groupid: groupID,
        membersUID: membersUID,
        membersUsername: finalGroupMembersUsername,
        // creator of the grp is the admin
        admins: List<String>.empty(growable: true)
          ..add(profileController.user.value.uid));

    try {
      await ref.set(newGroup.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }

  Future<void> deleteGroup(String groupID) async {
    await _db.collection("Groups").doc(groupID).delete();
  }

  // get a list of friends that matches the query (for creating groups)
  List<String> getFriendSuggestions(String query, List<String> friendsList) {
    List<String> matches = [];
    matches.addAll(friendsList);
    matches.retainWhere((c) => c.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  // from a list of usernames, return a list of the UIDs of those users
  Future<List<String>> getListOfFriendUidFromUsername(
      List<String> usernames) async {
    // get all Users documents where friend is to be added
    final friendSnapshot = await _db
        .collection("Users")
        .where("Username", whereIn: usernames)
        .get();
    return friendSnapshot.docs
        .map((snapshot) => snapshot.data()['UID'].toString())
        .toList();
  }

  Future<void> addMembersToGroup(String groupID, List<String> uidToAdd,
      List<String> groupUIDList, List<String> groupUsernameList) async {
    if (uidToAdd.isNotEmpty) {
      List<String> newGroupUIDList = List<String>.from(groupUIDList);
      List<String> newGroupUsernameList = List<String>.from(groupUsernameList);

      // friends to be added
      final friendSnapshot =
          await _db.collection("Users").where("UID", whereIn: uidToAdd).get();
      // add the new member UID if not inside
      if (friendSnapshot.docs.isNotEmpty) {
        // adds the uid to the new members UID list
        newGroupUIDList.addAll(uidToAdd);

        // adds the username to the new members Username list
        String friendUsername = friendSnapshot.docs.first.data()["Username"];
        newGroupUsernameList.add(friendUsername);
      }

      // update Firestore with the new lists
      await _db.collection('Groups').doc(groupID).update(
        {
          "MembersUID": newGroupUIDList,
          "MembersUsername": newGroupUsernameList
        },
      );
    }
  }

  Future<void> deleteMembersFromGroup(String groupID, String usernameToRemove,
      List<String> groupUIDList, List<String> groupUsernameList) async {
    if (usernameToRemove.isNotEmpty) {
      List<String> newGroupUIDList = List<String>.from(groupUIDList);
      List<String> newGroupUsernameList = List<String>.from(groupUsernameList);

      // friend to be removed
      final friendSnapshot = await _db
          .collection("Users")
          .where("Username", isEqualTo: usernameToRemove)
          .get();
      // if user exists and is inside the group
      if (friendSnapshot.docs.isNotEmpty &&
          groupUsernameList.contains(usernameToRemove)) {
        // remove the uid from the members UID list
        String friendUID = friendSnapshot.docs.first.data()["UID"];
        newGroupUIDList.remove(friendUID);

        // remove the username from members Username list
        newGroupUsernameList.remove(usernameToRemove);
      }

      // update Firestore with the new lists
      await _db.collection('Groups').doc(groupID).update(
        {
          "MembersUID": newGroupUIDList,
          "MembersUsername": newGroupUsernameList
        },
      );
    }
  }

  // --- SEND A MESSAGE TO GROUP --- //
  Future<void> sendMessageToGroup(String groupID, String name, String uid, String message) async {
    final newMessage = Messages(
        senderName: name,
        senderUID: uid,
        date: Timestamp.now(),
        message: message);
    try {
      await _db.collection("Groups").doc(groupID).collection("Messages").doc().set(newMessage.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }

  // --- FETCH ALL GROUP'S MESSAGES --- //
  Stream<QuerySnapshot> fetchGroupMessages(String groupID) {
    Stream<QuerySnapshot> result = _db
        .collection("Groups")
        // select group
        .doc(groupID)
        // get the Messages collection inside each group
        .collection("Messages")
        .orderBy("Date", descending: false)
        .snapshots();
    return result;
  }
}
