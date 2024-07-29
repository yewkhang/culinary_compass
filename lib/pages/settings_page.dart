import 'package:culinary_compass/pages/profile_page.dart';
import 'package:culinary_compass/services/auth.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:culinary_compass/utils/constants/misc.dart';
import 'package:culinary_compass/utils/controllers/profile_controller.dart';
import 'package:culinary_compass/wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatelessWidget {

  final AuthService _auth = AuthService(auth: FirebaseAuth.instance);
  final ProfileController profileController = Get.put(ProfileController());
  final ImagePicker imagePicker;

  SettingsPage({super.key, required this.imagePicker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Culinary Compass',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: CCColors.primaryColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            children: [

              const SizedBox(height: 25.0),

              // Settings Text
              const Text(
                "Settings",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25.0
                )
              ),

              const SizedBox(height: 40.0),

              SettingsRow(
                name: "Profile",
                icon: Icons.person,
                color: CCColors.secondaryColor,
                onTap: () {
                  Get.to(const ProfilePage(), transition: Transition.rightToLeftWithFade);
                }
              ),

              const SizedBox(height: 50.0),
              
              SettingsRow(
                name: "Log Out",
                icon: Icons.logout,
                color: Colors.red,
                onTap: () async {
                  await _auth.signOut();
                  Get.offAll(() => Wrapper(imagePicker: imagePicker), transition: Transition.rightToLeftWithFade); // also removes ALL Get Controllers
                }
              )
            ],
          ),
        ),
      )
    );
  }
}