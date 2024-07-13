import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  final String username;
  final String uid;
  final String bio;
  final String profileImageURL;
  final List<String> friendsUID;
  final List<String> friendsUsername;

  const MyUser({
    required this.username,
    required this.uid,
    required this.bio,
    required this.profileImageURL,
    required this.friendsUID,
    required this.friendsUsername
  });

  static MyUser empty() {
    return MyUser(
      username: "",
      uid: "",
      bio: "",
      profileImageURL: "",
      friendsUID: List<String>.empty(growable: true),
      friendsUsername: List<String>.empty(growable: true)
    );
  }

  Map<String, dynamic> toJsonNoNull() {
    return {
      "Username": username,
      "UID": uid,
      "Bio": bio,
      "Profile Image": profileImageURL,
      "FriendsUID": friendsUID,
      "FriendsUsername": friendsUsername
    };
  }

  factory MyUser.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final userData = snapshot.data()!;
    return MyUser(
        username: userData['Username'] ?? '',
        uid: userData['UID'] ?? '',
        bio: userData['Bio'] ?? '',
        profileImageURL: userData['Profile Image'] ?? '',
        friendsUID: List<String>.from(userData['FriendsUID'] ?? []),
        friendsUsername: List<String>.from(userData['FriendsUsername'] ?? [])
      );
  }

  Map<String, String> toJsonProfileImage() {
    return {
      "Profile Image": profileImageURL
    };
  }
}