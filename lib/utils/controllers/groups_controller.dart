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
  final ProfileController profileController = Get.find();

  // --------------------- OBS VARIABLES --------------------- //
  Rx<Groups> selectedGroup = Groups.empty().obs;

  // to clear the controller
  void reset() {
    selectedGroup(Groups.empty());
  }

  // fetch all groups that user is in
  Stream<QuerySnapshot> fetchAllUserGroups() {
    Stream<QuerySnapshot> result = _db
        .collection("Groups")
        // select logs where UID matches user ID
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

  Future<void> createGroup(
      String name, List<String> membersUID, List<String> membersUsername) async {
    // create a document reference in Firestore
    DocumentReference ref = _db.collection('Groups').doc();
    // get the ID of the new document reference. This will be the group's ID
    String groupID = ref.id;
    membersUID.add(_auth.currentUser!.uid);
    // Create Groups Model for new group
    final newGroup = Groups(
      name: name,
      groupid: groupID,
      membersUID: membersUID,
      membersUsername: membersUsername,
    );

    try {
      await ref.set(newGroup.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }
}
