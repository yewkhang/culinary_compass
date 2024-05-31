import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:culinary_compass/services/auth.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: Text('Culinary Compass'),
        backgroundColor: Colors.purple,
        elevation: 0.0,
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(Colors.black),
              backgroundColor: WidgetStateProperty.all(Colors.white),
              foregroundColor: null,
              textStyle: WidgetStateProperty.all(TextStyle(
                color: Colors.black
              ))
            ),
            label: Text('Log Out'),
            onPressed: () async {
              await _auth.signOut();
            },
          )
        ], // appears on top right of AppBar
      ),
    );
  }
}