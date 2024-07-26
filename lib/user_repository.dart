import 'dart:convert';
import 'package:culinary_compass/models/groups_model.dart';
import 'package:culinary_compass/models/logging_model.dart';
import 'package:culinary_compass/models/myuser.dart';
import 'package:culinary_compass/models/places_model.dart';
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
      String username,
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
        username: username,
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
      String username,
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
    } else {
      // a new picture is uploaded
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
          username: username,
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
  Future<void> uploadUserProfileImage(
      String selectedImagePath, String email) async {
    String imageURL = "";

    // --- Upload image to Firebase storage --- //
    String fileName =
        DateTime.now().millisecondsSinceEpoch.toString(); // creates file name
    String uid =
        _auth.currentUser!.uid; // gets uid for path on firestore database

    Reference refRoot = _storage.ref();
    Reference refDirectoryImages = refRoot.child("Profile Images");
    Reference refDirectoryUID = refDirectoryImages.child(uid);
    Reference profileImageToUpload =
        refDirectoryUID.child(fileName); // creates references for file path

    final file = File(selectedImagePath);
    try {
      await profileImageToUpload.putFile(file);
      imageURL = await profileImageToUpload.getDownloadURL();
    } catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }

    // --- Upload ProfileImage to Firestore --- //
    final profileImage =
        MyUser(
          username: "",
          uid: "",
          bio: "",
          profileImageURL: imageURL,
          friendsUID: List<String>.empty(growable: true),
          friendsUsername: List<String>.empty(growable: true)
          ); // other fields are null

    try {
      await _db
          .collection("Users")
          .doc(email)
          .update(profileImage.toJsonProfileImage());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }

  // Fetch all logs from user and friends
  Stream<QuerySnapshot> fetchAllFriendLogs(List<String> friendsUID)  {
    Stream<QuerySnapshot> result = _db
        .collection("Logs")
        // select logs where UID matches user ID and friends UID
        .where('UID',
            whereIn: friendsUID) 
        .snapshots();
    return result;
  }

  // Fetch all logs from specific friend
  Stream<QuerySnapshot> fetchSpecificFriendLogs(String friendUID)  {
    Stream<QuerySnapshot> result = _db
        .collection("Logs")
        // select logs where UID matches user ID and friends UID
        .where('UID',
            isEqualTo: friendUID) 
        .snapshots();
    return result;
  }

  // Fetch all logs from user and friends and return a list to be encoded to json
  Future<List<Map<String, dynamic>>> listOfFriendLogsFromUID(List<String> friendUIDs) async {
    friendUIDs.add(_auth.currentUser!.uid); // add user's logs into query
    QuerySnapshot result = await _db
        .collection("Logs")
        // select logs where UID matches user ID
        .where('UID',
            whereIn: friendUIDs) // list contains the users friends and themselves
        .get();
    return result.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<String> getFirestoreDataAsJson(List<String> friendUIDs) async {
    List<Map<String, dynamic>> data = await listOfFriendLogsFromUID(friendUIDs);
    String jsonData = jsonEncode(data);
    return jsonData;
  }

  // --- SAVE PLACES TO TRY --- //
  Future<void> savePlacesToTry(
      String name, String location, String comments) async {
    final newPlace = PlacesModel(
        uid: _auth.currentUser!.uid,
        name: name,
        location: location,
        description: comments);
    try {
      await _db.collection("Places").doc().set(newPlace.toJson());
    } on FirebaseException catch (e) {
      throw FirebaseException(plugin: 'Please try again');
    }
  }

  // --- DELETE USER PLACES --- //
  Future<void> deletePlacesToTry(String docID) {
    return _db.collection("Places").doc(docID).delete();
  }

  // --- FETCH USER PLACES TO TRY --- //
  Stream<QuerySnapshot> fetchPlacesToTry() {
    Stream<QuerySnapshot> result = _db
        .collection("Places")
        // select logs where UID matches user ID
        .where('UID', isEqualTo: _auth.currentUser!.uid)
        .snapshots();
    return result;
  }

    // --- FETCH USER DETAILS --- //
  Future<MyUser> fetchAllUserDetails() async {
    try {
      final result = await _db
          .collection("Users")
          .doc(_auth.currentUser!.email)
          .get();
      if (result.exists) {
        return MyUser.fromSnapshot(result);
      } else {
        return MyUser.empty();
      }
    } on Exception catch (e) {
      throw Exception("error in fetchAllUserDetails");
    }
  }

    // --- FETCH GROUP DETAILS --- //
  Future<Groups> fetchUserGroupDetails(String groupID) async {
    try {
      final result = await _db
          .collection("Groups")
          .doc(groupID)
          .get();
      if (result.exists) {
        return Groups.fromSnapshot(result);
      } else {
        return Groups.empty();
      }
    } on Exception catch (e) {
      throw Exception("error in fetchGroupDetails");
    }
  }

}
