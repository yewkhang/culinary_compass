import 'package:culinary_compass/authenticate/signin.dart';
import 'package:culinary_compass/authenticate/register.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  bool showSignInPage = true;
  void togglePageView() {
    setState(() => showSignInPage = !showSignInPage);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignInPage) {
      return SignIn(togglePageView: togglePageView);
    } else {
      return Register(togglePageView: togglePageView);
    }
  }
}