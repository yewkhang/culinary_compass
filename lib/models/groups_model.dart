import 'package:cloud_firestore/cloud_firestore.dart';

class Groups {
  final String name;
  final String groupid;
  final List<String> membersUID;
  final List<String> membersUsername;
  final List<String> admins;

  const Groups({
    required this.name,
    required this.groupid,
    required this.membersUID,
    required this.membersUsername,
    required this.admins
  });

  static Groups empty() {
    return Groups(
      name: "",
      groupid: "",
      membersUID: List<String>.empty(growable: true),
      membersUsername: List<String>.empty(growable: true),
      admins: List<String>.empty(growable: true)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Name": name,
      "GroupID": groupid,
      "MembersUID": membersUID,
      "MembersUsername": membersUsername,
      "Admins": admins
    };
  }

  factory Groups.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final groupData = snapshot.data()!;
    return Groups(
        name: groupData['Username'] ?? '',
        groupid: groupData['UID'] ?? '',
        membersUID: List<String>.from(groupData['FriendsUID'] ?? []),
        membersUsername: List<String>.from(groupData['FriendsUsername'] ?? []),
        admins: List<String>.from(groupData['FriendsUsername'] ?? [])
      );
  }
}