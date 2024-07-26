import 'package:cloud_firestore/cloud_firestore.dart';

class LoggingModel {
  final String uid;
  final String username;
  final String pictureURL;
  final String name;
  final String location;
  final double rating;
  final String description;
  final List<String> tags;

  const LoggingModel(
      {required this.uid,
      required this.username,
      required this.pictureURL,
      required this.name,
      required this.location,
      required this.rating,
      required this.description,
      required this.tags});

  Map<String, dynamic> toJson() {
    return {
      "UID": uid,
      "Username": username,
      "Picture": pictureURL,
      "Name": name,
      "Location": location,
      "Rating": rating,
      "Description": description,
      "Tags": tags,
    };
  }

  factory LoggingModel.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return LoggingModel(
        uid: data['UID'] ?? '',
        username: data["Username"] ?? '',
        pictureURL: data ['Picture'] ?? '',
        name: data ['Name'] ?? '',
        location: data['Location'] ?? '',
        rating: data['Rating'] ?? '',
        description: data['Description'] ?? '',
        tags: data['Tags'] ?? '',);
  }
}
