import 'package:culinary_compass/models/logging_model.dart';
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

  // Save user logs
  Future<void> saveUserLog(
      String selectedImagePath,
      String name,
      String location,
      double rating,
      String description,
      List<String> tags) async {
    // --- Upload image to Firebase storage --- //
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

    // --- Upload Log to Firestore --- //
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

  // Fetch user logs
  Stream<QuerySnapshot> fetchAllUserLogs() {
    Stream<QuerySnapshot> result = _db
        .collection("Logs")
        // select logs where UID matches user ID
        .where('UID', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
    return result;
  }

  // Delete user logs
  Future<void> deleteUserLog(String docID, String originalPictureURL) {
    // Delete image
    _storage.refFromURL(originalPictureURL).delete();
    return _db.collection("Logs").doc(docID).delete();
  }

  // Update user logs
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
    // Delete previous image
    if (originalPictureURL.isNotEmpty) {
      _storage.refFromURL(originalPictureURL).delete();
    }
    // --- Upload image to Firebase storage --- //
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
