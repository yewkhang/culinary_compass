import 'package:culinary_compass/authenticate/authenticate.dart';
import 'package:culinary_compass/homepage/homepage.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // return either home or authenticate --> is like the governing class
    return Authenticate();
  }
}