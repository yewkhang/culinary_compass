import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Culinary Compass'),
        backgroundColor: CCColors.primaryColor,
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: const Icon(Icons.person),
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(Colors.black),
              backgroundColor: WidgetStateProperty.all(Colors.white),
              foregroundColor: null,
            ),
            label: const Text('Log Out', style: TextStyle(color: Colors.black)),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ], // appears on top right of AppBar
      ),
    );
  }
}