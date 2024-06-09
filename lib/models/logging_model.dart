import 'dart:io';

class LoggingModel {
  final String? uid;
  final String pictureURL;
  final String name;
  final String location;
  final double rating;
  final String description;

  const LoggingModel({
    required this.uid,
    required this.pictureURL,
    required this.name,
    required this.location,
    required this.rating,
    required this.description
  });


  Map<String, dynamic> toJson() {
    return {
      "UID": uid,
      "Picture": pictureURL,
      "Name": name,
      "Location": location,
      "Rating": rating,
      "Description": description,
    };
  }
}