import 'package:culinary_compass/models/logging_model.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;


  // Save user logs
  Future<void> saveUserLog(String? uid, String selectedImagePath, String name,
      String location, double rating, String description) async {
    // --- Upload image to Firebase storage --- //
    String fileName = DateTime.now()
        .millisecondsSinceEpoch
        .toString(); // Save file as under this name
    String savedImageURL = ''; // Firebase URL to access image in the future
    final path = '$uid/images/$fileName'; // folder directory images are saved in
    final file = File(selectedImagePath);
    final ref = FirebaseStorage.instance.ref().child(path);
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
        description: description);
    try {
      await _db.collection("Logs").doc().set(newLog.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }
}
