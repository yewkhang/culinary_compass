import 'package:culinary_compass/pages/home.dart';
import 'package:culinary_compass/pages/logging_page.dart';
import 'package:culinary_compass/pages/settings_page.dart';
import 'package:culinary_compass/pages/socials_page.dart';
import 'package:culinary_compass/pages/yourlogs_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:culinary_compass/utils/constants/colors.dart';
import 'package:image_picker/image_picker.dart';

class NavigationMenu extends StatelessWidget {
  final int? pageIndex;
  final ImagePicker imagePicker;
  const NavigationMenu({super.key, this.pageIndex, required this.imagePicker});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController(imagePicker: imagePicker));
    if (pageIndex != null) {
      controller.selectedIndex.value = pageIndex!;
    }

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
            NavigationDestination(icon: Icon(Icons.people), label: 'Social'),
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
  final ImagePicker imagePicker;

  NavigationController({required this.imagePicker});

  static NavigationController get instance => Get.find();

  // Change when screens are created
  late final screens = [
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
      imagePicker: imagePicker
    ),
    SocialsPage(imagePicker: imagePicker),
    SettingsPage(imagePicker: imagePicker)
  ];
}
