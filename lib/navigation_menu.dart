import 'package:culinary_compass/home.dart';
import 'package:culinary_compass/pages/logging_page.dart';
import 'package:culinary_compass/pages/settings_page.dart';
import 'package:culinary_compass/pages/socials_page.dart';
import 'package:culinary_compass/pages/yourlogs_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:culinary_compass/utils/constants/colors.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 70, // height of navigation bar
          elevation: 0,
          backgroundColor: Colors.grey.shade100,
          indicatorColor: CCColors.primaryColor,
          selectedIndex:
              controller.selectedIndex.value, //access int wrapped in Rx context
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,

          destinations: const [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.book), label: 'Your Logs'),
            NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Log'),
            NavigationDestination(icon: Icon(Icons.people), label: 'Groups'),
            NavigationDestination(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  // observed current navigation page index
  final Rx<int> selectedIndex = 0.obs; // integer value wrapped in Rx context

  // Change when screens are created
  final screens = [
    const HomePage(),
    YourlogsPage(),
    LoggingPage(
      docID: '',
      name: '',
      location: '',
      description: '',
      originalPictureURL: '',
      tags: List<String>.empty(growable: true),
      rating: 0,
    ),
    SocialsPage(),
    SettingsPage()
  ];
}
