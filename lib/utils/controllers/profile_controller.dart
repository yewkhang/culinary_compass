import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/controllers/profileimage_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {

  // --------------------- FIREBASE --------------------- //
  // Firebase/Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  // --------------------- VARIABLES --------------------- //
  // User Repo for methods
  final UserRepository userRepository = Get.put(UserRepository());
  // Abstract away the image capturing part
  final ProfileImageController profileImageController = Get.put(ProfileImageController());



  // --------------------- GETTERS --------------------- //
  // (profile_controller).currentUser -> 
  User get currentUser => _auth.currentUser!;
  // (profile_controller).usersCollection
  CollectionReference get usersCollection => _firestore.collection("Users");
  // (profile_controller).userStream
  Stream<DocumentSnapshot> get userStream => usersCollection.doc(currentUser.email).snapshots();
  // (profile_controller).instance
  static ProfileController get instance => Get.find();




  // --------------------- OBS VARIABLES --------------------- //
  Rx<MyUser> user = MyUser.empty().obs;

  @override
  void onInit() async {
    super.onInit();
    fetchUserDetails();
  }

  // to clear the controller
  void reset() {
    user(MyUser.empty());
  }

  // fetch user details from Firebase document
  Future<void> fetchUserDetails() async {
    try {
      final MyUser user = await userRepository.fetchAllUserDetails();
      this.user(user);
    } catch (e) {
      print(e);
      user(MyUser.empty());
    }
  }

  Future<void> uploadProfileImage() async {
    await profileImageController.getImage(ImageSource.gallery);
    await userRepository.uploadUserProfileImage(
      profileImageController.selectedImagePath.value,
      currentUser.email!,
    );
    // updates on remote profile controller
    user(MyUser(
      username: user.value.username,
      uid: user.value.uid,
      bio: user.value.bio,
      profileImageURL: profileImageController.selectedImagePath.value,
      friendsUID: user.value.friendsUID,
      friendsUsername: user.value.friendsUsername
    ));
    // clear image path
    profileImageController.selectedImagePath.value = "";
  }

  Future<void> updateTextField(String field, String newValue) async {
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  Future<void> addFriendToList(String uid) async {
    if (uid.trim().isNotEmpty) {

      List<String> friendsUIDList = List<String>.from(user.value.friendsUID);
      List<String> friendsUsernameList = List<String>.from(user.value.friendsUsername);

      final friendSnapshot = await _firestore.collection("Users").where("UID", isEqualTo: uid).get();

      // add the new UID if not inside
      if (!friendsUIDList.contains(uid) && friendSnapshot.docs.isNotEmpty) {
        // adds the uid to the new friends UID list
        friendsUIDList.add(uid);
        friendsUIDList.sort();

        // adds the username to the new friends Username list
        String friendUsername = friendSnapshot.docs.first.data()["Username"];
        friendsUsernameList.add(friendUsername);
        friendsUsernameList.sort();

      }

        // update Firestore with the new lists
        await usersCollection.doc(currentUser.email).update({"FriendsUID": friendsUIDList});
        await usersCollection.doc(currentUser.email).update({"FriendsUsername": friendsUsernameList});

        // updates on remote profile controller
        user(MyUser(
          username: user.value.username,
          uid: user.value.uid,
          bio: user.value.bio,
          profileImageURL: user.value.profileImageURL,
          friendsUID: friendsUIDList,
          friendsUsername: friendsUsernameList
        ));
      
    }
  }

  // deletes friends from username
  Future<void> deleteFriendFromList(String username) async {
    if (username.trim().isNotEmpty) {
      
      List<String> friendsUIDList = List<String>.from(user.value.friendsUID);
      List<String> friendsUsernameList = List<String>.from(user.value.friendsUsername);

      final friendSnapshot = await _firestore.collection("Users").where("Username", isEqualTo: username).get();

      // add the new UID if not inside
      if (friendsUsernameList.contains(username) && friendSnapshot.docs.isNotEmpty) {
        // removes the corresponding UID from the friends UID list
        String friendUID = friendSnapshot.docs.first.data()["UID"];
        friendsUIDList.remove(friendUID);
        friendsUIDList.sort();
        print(friendsUIDList);

        // removes the username from the friends Username list
        friendsUsernameList.remove(username);
        friendsUsernameList.sort();
        print(friendsUsernameList);
      }

      // update Firestore with the new lists
      await usersCollection.doc(currentUser.email).update({
        "FriendsUID": friendsUIDList, 
        "FriendsUsername": friendsUsernameList
      });

      // updates on remote profile controller
      user(MyUser(
        username: user.value.username,
        uid: user.value.uid,
        bio: user.value.bio,
        profileImageURL: user.value.profileImageURL,
        friendsUID: friendsUIDList,
        friendsUsername: friendsUsernameList
      ));
    }
  }
}
