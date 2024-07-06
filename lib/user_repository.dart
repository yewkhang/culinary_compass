import 'package:culinary_compass/models/logging_model.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- SAVE USER LOGS --- //
  Future<void> saveUserLog(
      String selectedImagePath,
      String name,
      String location,
      double rating,
      String description,
      List<String> tags) async {
    // Upload image to Firebase storage
    String fileName = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Save file as under this name
    String savedImageURL = ''; // Firebase URL to access image in the future
    String uid = _auth.currentUser!.uid; // Current user uid
    final path =
        '$uid/images/$fileName'; // folder directory images are saved in
    final file = File(selectedImagePath);
    final ref = _storage.ref().child(path);
    try {
      await ref.putFile(file);
      savedImageURL = await ref.getDownloadURL();
    } catch (error) {
      'An error';
    }

    // Upload Log to Firestore
    final newLog = LoggingModel(
        uid: uid,
        pictureURL: savedImageURL,
        name: name,
        location: location,
        rating: rating,
        description: description,
        tags: tags);
    try {
      await _db.collection("Logs").doc().set(newLog.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }

  // --- FETCH USER LOGS --- //
  Stream<QuerySnapshot> fetchAllUserLogs() {
    Stream<QuerySnapshot> result = _db
        .collection("Logs")
        // select logs where UID matches user ID
        .where('UID', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
    return result;
  }

  // --- DELETE USER LOGS --- //
  Future<void> deleteUserLog(String docID, String originalPictureURL) {
    // Delete image
    _storage.refFromURL(originalPictureURL).delete();
    return _db.collection("Logs").doc(docID).delete();
  }

  // --- UPDATE USER LOGS --- //
  Future<void> updateUserLog(
      String docID,
      String originalPictureURL,
      String newSelectedImagePath,
      String name,
      String location,
      double rating,
      String description,
      List<String> tags) async {
        
    String uid = _auth.currentUser!.uid; // Current user uid

    // original image is the same as the new image, dont change on Firebase
    if (originalPictureURL == newSelectedImagePath) {
      // update logs without updating picture
      return _db.collection("Logs").doc(docID).update({
        'Name': name,
        'Location': location,
        'Description': description,
        'Rating': rating,
        'Tags': tags,
        'UID': uid
      });
    } else { // a new picture is uploaded
      // Delete previous image
      if (originalPictureURL.isNotEmpty) {
        _storage.refFromURL(originalPictureURL).delete();
      }
      // Upload NEW image to Firebase storage
      String fileName = DateTime.now()
          .millisecondsSinceEpoch
          .toString(); // Save file as under this name
      String newPictureURL = ''; // Firebase URL to access image in the future
      final path =
          '$uid/images/$fileName'; // folder directory images are saved in
      final file = File(newSelectedImagePath);
      final ref = _storage.ref().child(path);
      try {
        await ref.putFile(file);
        newPictureURL = await ref.getDownloadURL();
      } catch (error) {
        'An error';
      }
      final updatedLog = LoggingModel(
          uid: uid,
          pictureURL: newPictureURL,
          name: name,
          location: location,
          rating: rating,
          description: description,
          tags: tags);
      return _db.collection("Logs").doc(docID).update(updatedLog.toJson());
    }
  }
  // Uploads user profile image
  Future<void> uploadUserProfileImage(String selectedImagePath, String email) async {

    String imageURL = "";

    // --- Upload image to Firebase storage --- //
    String fileName = DateTime.now().millisecondsSinceEpoch.toString(); // creates file name
    String uid = _auth.currentUser!.uid; // gets uid for path on firestore database

    Reference refRoot = _storage.ref();
    Reference refDirectoryImages = refRoot.child("Profile Images");
    Reference refDirectoryUID = refDirectoryImages.child(uid);
    Reference profileImageToUpload = refDirectoryUID.child(fileName); // creates references for file path
    
    final file = File(selectedImagePath);
    try {
      await profileImageToUpload.putFile(file);
      imageURL = await profileImageToUpload.getDownloadURL();
    } catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }

    // --- Upload ProfileImage to Firestore --- //
    final profileImage = MyUser(profileImageURL: imageURL); // other fields are null

    try {
      await _db.collection("Users").doc(email).update(profileImage.toJsonProfileImage());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }

  }
}
