import 'package:cloud_firestore/cloud_firestore.dart';

class Messages { //dont need groupID as Messages collection is nested within the group
  final String senderName;
  final String senderUID;
  final String date;
  final String message;

  const Messages({
    required this.senderName,
    required this.senderUID,
    required this.date,
    required this.message
  });

  static Messages empty() {
    return const Messages(
      senderName: "",
      senderUID: "",
      date: "",
      message: "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "Name": senderName,
      "UID": senderUID,
      "Date": date,
      "Message": message
    };
  }

  factory Messages.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    return Messages(
        senderName: data['Name'] ?? '',
        senderUID: data['UID'] ?? '',
        date: data['Date'] ?? '',
        message: data['Message'] ?? '',
      );
  }
}