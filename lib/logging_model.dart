// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoggingModel {
  final String? id;
  final Image picture;
  final String name;
  final String location;

  const LoggingModel({
    this.id,
    required this.picture,
    required this.name,
    required this.location,
  });

  toJson() {
    return {
      "Picture": picture,
      "Name": name,
      "Location": location
    };
  }
}