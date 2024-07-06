import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String? username;
  final String? uid;
  final String? bio;
  final String? profileImageURL;
  final List<String>? friends;

  const MyUser({
    this.username,
    this.uid,
    this.bio,
    this.profileImageURL,
    this.friends
  });

  Map<String, dynamic> toJsonNoNull() {
    return {
      "Username": username,
      "UID": uid,
      "Bio": bio,
      "Profile Image": profileImageURL,
      "Friends": friends
    };
  }

  factory MyUser.fromJsonNoNull(DocumentSnapshot snapshot) {
    final userData = snapshot.data() as Map<String, dynamic>;
    return MyUser(
        username: userData['username'] ?? '',
        uid: userData['uid'] ?? '',
        bio: userData['bio'] ?? '',
        profileImageURL: userData['profileImageURL'] ?? '',
        friends: userData['friends'] ?? ''
      );
  }

  Map<String, String> toJsonProfileImage() {
    return {
      "Profile Image": profileImageURL!
    };
  }
}