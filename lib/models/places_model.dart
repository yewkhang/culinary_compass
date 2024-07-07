import 'package:cloud_firestore/cloud_firestore.dart';

class PlacesModel {
  final String? uid;
  final String name;
  final String location;
  final String description;

  const PlacesModel({
    required this.uid,
    required this.name,
    required this.location,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      "UID": uid,
      "Name": name,
      "Location": location,
      "Description": description,
    };
  }

  factory PlacesModel.fromJson(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return PlacesModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      description: data['description'] ?? '',
    );
  }
}
