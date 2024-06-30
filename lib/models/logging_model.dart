import 'package:cloud_firestore/cloud_firestore.dart';

class LoggingModel {
  final String? uid;
  final String pictureURL;
  final String name;
  final String location;
  final double rating;
  final String description;
  final List<String> tags;

  const LoggingModel(
      {required this.uid,
      required this.pictureURL,
      required this.name,
      required this.location,
      required this.rating,
      required this.description,
      required this.tags});

  Map<String, dynamic> toJson() {
    return {
      "UID": uid,
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
        uid: data['uid'] ?? '',
        pictureURL: data ['pictureURL'] ?? '',
        name: data ['name'] ?? '',
        location: data['location'] ?? '',
        rating: data['rating'] ?? '',
        description: data['description'] ?? '',
        tags: data['tags'] ?? '',);
  }
}
