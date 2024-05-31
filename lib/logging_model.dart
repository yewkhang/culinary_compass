// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoggingModel {
  final String? id;
  final Image picture;
  final String name;
  final String location;
  final String? description; // Description is optional

  const LoggingModel({
    this.id,
    required this.picture,
    required this.name,
    required this.location,
    this.description
  });

  toJson() {
    return {
      "Picture": picture,
      "Name": name,
      "Location": location,
      "Description": description
    };
  }
}