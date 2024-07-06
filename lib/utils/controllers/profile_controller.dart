import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/user_repository.dart';
import 'package:culinary_compass/utils/controllers/profileimage_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {

  // Firebase/Firestore instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Repo for methods
  final UserRepository userRepository = Get.put(UserRepository());

  // Abstract away the image capturing part
  final ProfileImageController profileImageController = Get.put(ProfileImageController());

  // (profile_controller).currentUser -> 
  User get currentUser => _auth.currentUser!;
  // (profile_controller).usersCollection
  CollectionReference get usersCollection => _firestore.collection("Users");
  // (profile_controller).userStream
  Stream<DocumentSnapshot> get userStream => usersCollection.doc(currentUser.email).snapshots();

  Future<void> uploadProfileImage() async {
    await profileImageController.getImage(ImageSource.gallery);
    await userRepository.uploadUserProfileImage(
      profileImageController.selectedImagePath.value,
      currentUser.email!,
    );
    profileImageController.selectedImagePath.value = ""; // clear image path
  }

  Future<void> updateTextField(String field, String newValue) async {
    if (newValue.trim().isNotEmpty) {
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }
}
