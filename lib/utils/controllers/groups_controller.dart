import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/models/groups_model.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // --------------------- OBS VARIABLES --------------------- //
  Rx<Groups> selectedGroup = Groups.empty().obs;

  // --------------------- GETTERS --------------------- //
  static GroupsController get instance => Get.find();

  // to clear the controller
  void reset() {
    selectedGroup(Groups.empty());
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

  // fetch group details from Firebase document
  Future<void> fetchGroupDetails(String groupID) async {
    try {
      final Groups group = await userRepository.fetchUserGroupDetails(groupID);
      selectedGroup(group);
    } catch (e) {
      print(e);
      selectedGroup(Groups.empty());
    }
  }

  Future<void> createGroup(String name, List<String> membersUID,
      List<String> membersUsername) async {
    // create a document reference in Firestore
    DocumentReference ref = _db.collection('Groups').doc();
    // get the ID of the new document reference. This will be the group's ID
    String groupID = ref.id;
    // add UID and Name of user making the group
    membersUID.add(_auth.currentUser!.uid);
    List<String> finalGroupMembersUsername = List.from(membersUsername)
      ..add(profileController.user.value.username);
    // Create Groups Model for new group
    final newGroup = Groups(
      name: name,
      groupid: groupID,
      membersUID: membersUID,
      membersUsername: finalGroupMembersUsername,
    );

    try {
      await ref.set(newGroup.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }

  // get a list of friends that matches the query (for creating groups)
  List<String> getFriendSuggestions(String query, List<String> friendsList) {
    List<String> matches = [];
    matches.addAll(friendsList);
    matches.retainWhere((c) => c.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  // from a list of usernames, return a list of the UIDs of those users
  Future<List<String>> getListOfFriendUidFromUsername(List<String> usernames) async {
    // get all Users documents where friend is to be added
    final friendSnapshot = await _db
        .collection("Users")
        .where("Username", whereIn: usernames)
        .get();
    return friendSnapshot.docs.map((snapshot) => snapshot.data()['UID'].toString()).toList();
  }
}
