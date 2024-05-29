import 'package:culinary_compass/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  // to access auth services
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[100],
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        elevation: 0.0, // drop shadow
        title: Text('Sign in to Culinary Compass'),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: ElevatedButton(
          child: Text('Sign In Anonymously'),
          // when tapping the button, returns signInAnon method in auth
          onPressed: () async {
            dynamic result = await _auth.signInAnon();
            if (result == null) {
              print("Error Signing In!");
            } else {
              print("Signed In!");
              print("User's uid: " + result.uid);
            }
          },
        )
      )
    );
  }
}